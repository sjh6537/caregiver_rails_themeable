require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'
require 'fileutils'

class HealthReportCrawler
  include Sidekiq::Worker
  sidekiq_options retry: false

  DEBUG = false

  # Asus settings
  ICODE = 'K00016'
  KEY = 'K00016yFjdKGNeVF'

  # 網址和路徑設定
  POST_URL = 'http://127.0.0.1/health/send_message'
  USER_INFO_FOLDER = "#{Rails.root}/health"
  HEALTH_REPORTS_PATH = "#{Rails.root}/tmp/health_reports"

  def perform
    run
  ensure
  end

  private

  def log(message)
    puts message if DEBUG
  end

  def aes_key_iv(str_key)
    key = str_key[0...16].encode('utf-8')
    iv = str_key[0...16].encode('utf-8')
    [key, iv]
  end

  def aes_cbc_encrypt(key, raw_string)
    key_bytes, iv = aes_key_iv(key)

    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.encrypt
    cipher.key = key_bytes
    cipher.iv = iv

    encrypted = cipher.update(raw_string) + cipher.final
    Base64.strict_encode64(encrypted)
  end

  def aes_cbc_decrypt(key, enc_string)
    key_bytes, iv = aes_key_iv(key)

    decipher = OpenSSL::Cipher.new('AES-128-CBC')
    decipher.decrypt
    decipher.key = key_bytes
    decipher.iv = iv

    encrypted = Base64.decode64(enc_string)
    decipher.update(encrypted) + decipher.final
  end

  def get_vital_signs(icode, encrypted_id, start_time, end_time)
    url = URI.parse('https://hhds.asus-healthcare.com/healthhubapi/api/FS/V1/getvitalsignbyid')

    headers = {
      'Content-type' => 'application/json',
      'icode' => icode
    }

    data = {
      'icode' => icode,
      'id' => encrypted_id,
      'starttime' => start_time,
      'endtime' => end_time
    }

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url.path, headers)
    request.body = data.to_json

    response = http.request(request)

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      { error: "#{response.code}, #{response.body}" }
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
    # 確保目錄存在
    FileUtils.mkdir_p(HEALTH_REPORTS_PATH) unless Dir.exist?(HEALTH_REPORTS_PATH)

    # 修改：從資料庫中獲取使用者的身分證字號，而不是從檔案中取得
    id_card_list = User.where.not(id_number: [nil, '']).pluck(:id_number)

    # 將所有的使用者身分證字號加密
    all_IDs = id_card_list.join(',')
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

    data_dict.keys.each do |id_num|
      data_dict_post = Marshal.load(Marshal.dump(data_dict[id_num])) # 深度複製
      pop_timestamp(data_dict_post)

      health_report_file = File.join(HEALTH_REPORTS_PATH, "#{id_num}.json")

      if File.exist?(health_report_file)
        old_data = JSON.parse(File.read(health_report_file))

        with_different = false
        old_data.each do |category, values|
          next if category == 'User_id'

          # 比較舊資料與新資料的測量時間，檢查是否有更新的測量結果
          if old_data[category]['measure_time'] != data_dict[id_num][category]['measure_time']
            with_different = true
            break
          end
        end

        # 如果發現有新的測量資料，則更新本地文件並將新資料加入待發送清單
        if with_different
          all_result << data_dict_post
          File.write(health_report_file, JSON.pretty_generate(data_dict[id_num]))
        end
      else
        # 第一次量測，直接將資料保存並加入待發送清單
        all_result << data_dict_post
        File.write(health_report_file, JSON.pretty_generate(data_dict[id_num]))
      end
    end

    # 將新的量測資料送回稻相顧資料庫（並推播）
    return unless all_result.any?

    uri = URI.parse(POST_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = all_result.to_json

    response = http.request(request)

    log("Post status Code: #{response.code}")
    log("Post response: #{response.body}")
  end
end
