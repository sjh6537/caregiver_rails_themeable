require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'
require 'fileutils'

class HealthReportCrawler
  class Error < StandardError; end
  class APIError < Error; end
  class EncryptionError < Error; end

  # Asus settings
  ICODE = 'K00016'
  KEY = 'K00016yFjdKGNeVF'

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
  def aes_cbc_encrypt(key, raw_string)
    return '' if key.nil? || raw_string.nil?

    key_bytes, iv = aes_key_iv(key)

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
  def aes_cbc_decrypt(key, enc_string)
    return '' if key.nil? || enc_string.nil? || enc_string.empty?

    key_bytes, iv = aes_key_iv(key)

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

  def get_vital_signs(icode, encrypted_id, start_time, end_time)
    # 根據環境使用不同的 URL
    base_url = if Rails.env.production?
                 'https://hhds.asus-healthcare.com'
               else
                 'https://stage-hhds.asus-healthcare.com'
               end

    url = URI.parse("#{base_url}/healthhubapi/api/FS/V1/getvitalsignbyid")

    headers = {
      'Content-Type' => 'application/json',
      'icode' => icode
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
      end
    end

    # 處理血紅素數據 (HB)
    if user_info['HB'].length > 0
      user_info['HB'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['HB']['hb'] = item['hb'].to_f
        user_data[user_id]['HB']['measure_time'] = item['measure_time']
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
      end
    end

    # 處理總膽固醇數據 (TC)
    if user_info['TC'].length > 0
      user_info['TC'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['TC']['tc'] = item['tc'].to_f
        user_data[user_id]['TC']['measure_time'] = item['measure_time']
      end
    end

    # 處理尿酸數據 (UA)
    if user_info['UA'].length > 0
      user_info['UA'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['UA']['ua'] = item['ua'].to_f
        user_data[user_id]['UA']['measure_time'] = item['measure_time']
      end
    end

    # 處理氧氣飽和數據 (OHB)
    if user_info['OHB'].length > 0
      user_info['OHB'].reverse_each do |item|
        user_id = item['id']
        user_data[user_id] ||= create_empty_dict(user_id)

        user_data[user_id]['OHB']['ohb'] = item['ohb'].to_f
        user_data[user_id]['OHB']['measure_time'] = item['measure_time']
      end
    end

    user_data
  end

  def pop_timestamp(data_dict)
    data_dict.each do |category, values|
      if data_dict[category].is_a?(Hash) && data_dict[category].key?('measure_time')
        data_dict[category].delete('measure_time')
      end
    end
  end

  def run
    log('Starting health report crawling')
    # 修改：從資料庫中獲取使用者的身分證字號，而不是從檔案中取得
    id_card_list = User.where.not(id_card: [nil, '']).pluck(:id_card)

    if id_card_list.empty?
      log('No users found with ID cards')
      return
    end

    # 將所有的使用者身分證字號加密
    all_IDs = id_card_list.join(',')
    log("Processing #{id_card_list.size} users")
    log("All IDs: #{all_IDs}")
    encrypted_id = aes_cbc_encrypt(KEY, all_IDs)

    # 從Asus的server爬所有使用者的量測資料
    current_date = DateTime.now.strftime('%Y-%m-%d')
    start_time = "#{current_date} 00:00:00"
    end_time = "#{current_date} 23:59:59"

    vital_signs = get_vital_signs(ICODE, encrypted_id, start_time, end_time)
    user_info = aes_cbc_decrypt(KEY, vital_signs['data'])
    data_dict = extract_data(user_info)

    # 從爬回來的使用者身份證字號，檢查是否有新的量測資料
    all_result = []
    success_count = 0
    error_count = 0

    data_dict.keys.each do |id|
      # 尋找對應的使用者
      user = User.find_by(id_card: id)
      next unless user

      process_user_data(user, data_dict[id], all_result)
      success_count += 1
    rescue StandardError => e
      error_count += 1
      log("Error processing user #{id}: #{e.message}", :error)
    end

    log("Processed #{success_count} users successfully, #{error_count} errors")

    # 將新的量測資料送回稻相顧資料庫（並推播）
    send_health_data(all_result) if all_result.any?
  rescue StandardError => e
    log("Critical error in health report crawler: #{e.message}", :error)
    Rails.logger.error e.backtrace.join("\n")
  end

  private

  def process_user_data(user, user_data, all_result)
    data_dict_post = Marshal.load(Marshal.dump(user_data)) # 深度複製
    pop_timestamp(data_dict_post)

    return unless new_measurements?(user, user_data)

    all_result << data_dict_post
    save_health_report(user, user_data)
  end

  def new_measurements?(user, data)
    %w[TP BP BS OX HB BW TC UA OHB].any? do |category|
      measure_time = data[category]['measure_time']
      next false if measure_time == 0

      begin
        measure_datetime = DateTime.parse(measure_time.to_s)
        !existing_measurement?(user, category, measure_datetime, data[category])
      rescue StandardError => e
        log("Error checking measurements for #{category}: #{e.message}", :error)
        false
      end
    end
  end

  def existing_measurement?(user, category, measure_datetime, data)
    case category
    when 'TP'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        temperature: data['temperature']
      )
    when 'BP'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        blood_pressure1: data['sbp'],
        blood_pressure2: data['dbp'],
        heart_rate: data['hb']
      )
    when 'BS'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        blood_sugar: data['bs'],
        hemoglobin: data['hg'],
        hematocrit: data['hct']
      )
    when 'OX'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        blood_oxygen: data['oxygen']
      )
    when 'BW'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        weight: data['bw'],
        bmi: data['bmi']
      )
    when 'TC'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        total_cholesterol: data['tc']
      )
    when 'UA'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        uric_acid: data['ua']
      )
    when 'OHB'
      user.health_reports.exists?(
        measure_time: measure_datetime,
        ketones: data['ohb']
      )
    else
      false
    end
  end

  def send_health_data(data)
    return if data.empty?

    uri = URI.parse(post_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = Settings.health_report.timeout || 30
    http.open_timeout = Settings.health_report.timeout || 30

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = data.to_json

    response = http.request(request)

    unless response.code.to_s.start_with?('2')
      log("Failed to send health data. Status: #{response.code}, Body: #{response.body}", :error)
      raise APIError, "Failed to send health data: #{response.code}"
    end

    log("Successfully sent health data for #{data.size} users")
  rescue StandardError => e
    log("Error sending health data: #{e.message}", :error)
    raise APIError, "Failed to send health data: #{e.message}"
  end

  def save_health_report(user, data)
    report = user.health_reports.new(
      measure_time: DateTime.now,
      temperature: data['TP']['temperature'] == 0 ? nil : data['TP']['temperature'],
      blood_pressure1: data['BP']['sbp'] == 0 ? nil : data['BP']['sbp'],
      blood_pressure2: data['BP']['dbp'] == 0 ? nil : data['BP']['dbp'],
      heart_rate: data['BP']['hb'] == 0 ? nil : data['BP']['hb'].to_i,
      blood_sugar: data['BS']['bs'] == 0 ? nil : data['BS']['bs'].to_i,
      hemoglobin: data['BS']['hg'] == 0 ? nil : data['BS']['hg'],
      hematocrit: data['BS']['hct'] == 0 ? nil : data['BS']['hct'],
      blood_oxygen: data['OX']['oxygen'] == 0 ? nil : data['OX']['oxygen'].to_i,
      weight: data['BW']['bw'] == 0 ? nil : data['BW']['bw'],
      bmi: data['BW']['bmi'] == 0 ? nil : data['BW']['bmi'],
      total_cholesterol: data['TC']['tc'] == 0 ? nil : data['TC']['tc'],
      uric_acid: data['UA']['ua'] == 0 ? nil : data['UA']['ua'],
      ketones: data['OHB']['ohb'] == 0 ? nil : data['OHB']['ohb']
    )
    report.save!
  rescue StandardError => e
    log("Error saving health report for user #{user.id}: #{e.message}", :error)
    raise
  end
end
