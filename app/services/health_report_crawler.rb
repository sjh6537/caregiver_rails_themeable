require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'
require 'fileutils'

class HealthReportCrawler
  include ReportHelper
  include LineHelper
  class Error < StandardError; end
  class APIError < Error; end
  class EncryptionError < Error; end

  attr_reader :icode, :key

  # 建立爬蟲實例時接收參數
  def initialize(icode: nil, key: nil)
    @icode = icode
    @key = key
    @community = CommunityProfile.find_by(icode: icode).community
  end

  private

  def log(message, level = :info)
    Rails.logger.send(level, "[HealthReportCrawler] #{message}") if Rails.env.development? || level != :debug
  end

  def post_url
    Settings.health_report.post_url
  end

  # 生成 AES 金鑰和初始向量
  # @param str_key [String] 用於生成金鑰和初始向量的字串
  # @return [Array<String>] 金鑰和初始向量的陣列
  def aes_key_iv(str_key)
    # 使用 UTF-8 編碼金鑰字串
    key_bytes = str_key.encode('UTF-8').bytes
    iv = key_bytes.dup

    # 確保金鑰和 IV 長度為 16 bytes
    key_bytes = key_bytes.take(16).fill(0, key_bytes.length...16)
    iv = iv.take(16).fill(0, iv.length...16)

    [key_bytes.pack('C*'), iv.pack('C*')]
  end

  # AES CBC 加密方法
  # @param key [String] 加密金鑰
  # @param raw_string [String] 要加密的原始字串
  # @return [String] Base64 編碼的加密字串
  def aes_cbc_encrypt(raw_string)
    return '' if @key.nil? || raw_string.nil?

    key_bytes, iv = aes_key_iv(@key)

    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.encrypt
    cipher.key = key_bytes
    cipher.iv = iv

    encrypted = cipher.update(raw_string) + cipher.final
    Base64.strict_encode64(encrypted)
  rescue StandardError => e
    log("加密錯誤: #{e.message}", :error)
    raise EncryptionError, "加密失敗: #{e.message}"
  end

  # AES CBC 解密方法
  # @param key [String] 解密金鑰
  # @param enc_string [String] Base64 編碼的加密字串
  # @return [String] 解密後的原始字串
  def aes_cbc_decrypt(enc_string)
    return '' if @key.nil? || enc_string.nil? || enc_string.empty?

    key_bytes, iv = aes_key_iv(@key)

    decipher = OpenSSL::Cipher.new('AES-128-CBC')
    decipher.decrypt
    decipher.key = key_bytes
    decipher.iv = iv

    begin
      encrypted = Base64.strict_decode64(enc_string.strip)
      decipher.update(encrypted) + decipher.final
    rescue ArgumentError => e
      log("Base64 解碼錯誤: #{e.message}", :error)
      raise EncryptionError, "無效的 Base64 編碼: #{e.message}"
    rescue OpenSSL::Cipher::CipherError => e
      log("解密錯誤: #{e.message}", :error)
      raise EncryptionError, "解密失敗: #{e.message}"
    end
  end

  def get_vital_signs(encrypted_id, start_time, end_time)
    # 根據環境使用不同的 URL
    base_url = if Rails.env.production?
                 'https://hhds.asus-healthcare.com'
               else
                 'https://stage-hhds.asus-healthcare.com'
               end

    url = URI.parse("#{base_url}/healthhubapi/api/FS/V1/getvitalsignbyid")

    headers = {
      'Content-Type' => 'application/json',
      'icode' => @icode
    }

    data = {
      id: encrypted_id,
      starttime: start_time,
      endtime: end_time
    }

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.read_timeout = 30
    http.open_timeout = 30

    begin
      request = Net::HTTP::Post.new(url.path, headers)
      request.body = data.to_json

      response = http.request(request)

      case response.code.to_i
      when 200
        JSON.parse(response.body)
      when 401
        log("API 認證失敗: #{response.body}", :error)
        raise APIError, 'API 認證失敗'
      when 404
        log("API 端點不存在: #{response.body}", :error)
        raise APIError, 'API 端點不存在'
      else
        log("API 呼叫失敗: #{response.code}, #{response.body}", :error)
        raise APIError, "API 回傳錯誤: #{response.code}, #{response.body}"
      end
    rescue JSON::ParserError => e
      log("JSON 解析錯誤: #{e.message}", :error)
      raise APIError, "回傳資料格式錯誤: #{e.message}"
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      log("API 超時: #{e.message}", :error)
      raise APIError, 'API 請求超時'
    rescue StandardError => e
      log("發生未預期的錯誤: #{e.message}", :error)
      raise APIError, "API 呼叫失敗: #{e.message}"
    end
  end

  def create_empty_dict(user_id)
    default_value = 0
    {
      'User_id' => user_id,
      'measure_time' => default_value,
      'TP' => { 'temperature' => default_value, 'measure_time' => default_value },
      'BP' => { 'sbp' => default_value, 'dbp' => default_value, 'hb' => default_value,
                'measure_time' => default_value },
      'BS' => { 'bs' => default_value, 'hg' => default_value, 'hct' => default_value, 'measure_time' => default_value },
      'OX' => { 'oxygen' => default_value, 'hb' => default_value, 'measure_time' => default_value },
      'HB' => { 'hb' => default_value, 'measure_time' => default_value },
      'BW' => { 'bw' => default_value, 'bmi' => default_value, 'measure_time' => default_value },
      'TC' => { 'tc' => default_value, 'measure_time' => default_value },
      'UA' => { 'ua' => default_value, 'measure_time' => default_value },
      'OHB' => { 'ohb' => default_value, 'measure_time' => default_value }
    }
  end

  def extract_data(user_info)
    user_info = JSON.parse(user_info)

    user_data = {}

    # 處理體溫數據 (TP)
    if user_info['TP'].length > 0
      user_info['TP'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['TP']['temperature'] = item['temperature'].to_f
        user_data[user_id]['TP']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理血壓數據 (BP)
    if user_info['BP'].length > 0
      user_info['BP'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['BP']['sbp'] = item['sbp'].to_f
        user_data[user_id]['BP']['dbp'] = item['dbp'].to_f
        user_data[user_id]['BP']['hb'] = item['hb'].to_f
        user_data[user_id]['BP']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理血糖數據 (BS)
    if user_info['BS'].length > 0
      user_info['BS'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['BS']['bs'] = item['bs'].to_f
        user_data[user_id]['BS']['hg'] = item['hg'].to_f
        user_data[user_id]['BS']['hct'] = item['hct'].to_f
        user_data[user_id]['BS']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理氧氣數據 (OX)
    if user_info['OX'].length > 0
      user_info['OX'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['OX']['oxygen'] = item['oxygen'].to_f
        user_data[user_id]['OX']['hb'] = item['hb'].to_f
        user_data[user_id]['OX']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理血紅素數據 (HB)
    if user_info['HB'].length > 0
      user_info['HB'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['HB']['hb'] = item['hb'].to_f
        user_data[user_id]['HB']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理體重數據 (BW)
    if user_info['BW'].length > 0
      user_info['BW'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['BW']['bw'] = item['bw'].to_f
        user_data[user_id]['BW']['bmi'] = item['bmi'].to_f
        user_data[user_id]['BW']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理總膽固醇數據 (TC)
    if user_info['TC'].length > 0
      user_info['TC'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['TC']['tc'] = item['tc'].to_f
        user_data[user_id]['TC']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理尿酸數據 (UA)
    if user_info['UA'].length > 0
      user_info['UA'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)
        user_data[user_id]['UA']['ua'] = item['ua'].to_f
        user_data[user_id]['UA']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end

    # 處理血氧數據 (OHB)
    if user_info['OHB'].length > 0
      user_info['OHB'].reverse_each do |item|
        user_id = item['id'
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['OHB']['ohb'] = item['ohb'].to_f
        user_data[user_id]['OHB']['measure_time'] = item['measure_time']
        # 更新最近的量測時間
        user_data[user_id]['measure_time'] = [user_data[user_id]['measure_time'], item['measure_time']].max
      end
    end
    user_data
  end

  # 刪除時間戳記
  def pop_timestamp(data_dict)
    data_dict.each do |category, values|
      values.delete('measure_time') if values.is_a?(Hash)
    end
  end

  # 抓取並處理健康數據
  def fetch_and_process_health_data
    # 取得所有使用者的身分證字號
    user_infos = @community.users.pluck(:id_card)
    # 除去空值
    raw_string = user_infos.reject(&:blank?)

    # 將所有的使用者身分證字號加密
    all_ids = raw_string.join(',')
    encrypted_id = aes_cbc_encrypt(all_ids)

    # 從Asus的server爬所有使用者的量測資料
    current_date = Time.now
    date_string = current_date.strftime('%Y-%m-%d')
    start_time = "#{date_string} 00:00:00"
    end_time = "#{date_string} 23:59:59"

    vital_signs = get_vital_signs(encrypted_id, start_time, end_time)
    # 解密回來的資料
    user_info = aes_cbc_decrypt(vital_signs['data'])
    data_dict = extract_data(user_info)

    # 從爬回來的使用者身份證字號, 檢查是否有新的量測資料
    all_result = []

    data_dict.keys.each do |id_card|
      # 檢查使用者是否存在
      user = @community.users.find_by(id_card: id_card)
      next unless user

      data_dict_post = Marshal.load(Marshal.dump(data_dict[id_card])) # 深度複製
      pop_timestamp(data_dict_post) if defined?(pop_timestamp)

      # 檢查使用者是否有新的量測資料
      last_record = user.health_records.order('measure_time DESC').first
      next if last_record && last_record.measure_time >= data_dict[id_card]['measure_time']

      # 將新的量測資料加入到 all_result 陣列中
      all_result << {
        user_id: id_card,
        data: data_dict_post
      }
    end

    return nil unless all_result.any?
    # 將新的量測資料送回稻相顧資料庫(並推播)
    
    saved_reports = []
    all_result.each do |result|
      user = @community.users.find_by(id_card: result[:user_id])
      next unless user

      # 將資料轉換為 HealthRecord 物件
      report = UserHealthReport.new(
        user_id: user.id,
        measure_time: Time.at(result[:data]['measure_time']),
        bmi: result[:data]['BW']['bmi'],
        weight: result[:data]['BW']['bw'],
        heart_rate: result[:data]['BP']['hb'].to_i,
        blood_pressure1: result[:data]['BP']['sbp'].to_i,
        blood_pressure2: result[:data]['BP']['dbp'].to_i,
        blood_sugar: result[:data]['BS']['bs'].to_i,
        blood_oxygen: result[:data]['OX']['oxygen'].to_i,
        temperature: result[:data]['TP']['temperature'],
        hemoglobin: result[:data]['OX']['hb'],
        hematocrit: result[:data]['BS']['hct'],
        uric_acid: result[:data]['UA']['ua'],
        total_cholesterol: result[:data]['TC']['tc']
      )

      # 儲存健康紀錄
      if report.save
        log("健康紀錄已儲存，使用者 ID：#{user.id}")
        # 推播通知發送給用戶
        message_push(user.account, format_health_report(report))
        saved_reports << { user_id: user.id, report_id: report.id }
      else
        log("健康紀錄儲存失敗，使用者 ID：#{user.id}，錯誤：#{report.errors.full_messages.join(', ')}", :error)
      end
    end
    
    return { processed: all_result.size, saved: saved_reports }
  end
end
