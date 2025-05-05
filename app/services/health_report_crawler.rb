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

  attr_reader :icode, :key

  # 建立爬蟲實例時接收參數
  def initialize(icode: nil, key: nil)
    @icode = icode || get_icode_from_community_profile
    @key = key || get_key_from_community_profile
  end

  private

  def get_icode_from_community_profile
    # 從 CommunityProfile 模型取得 icode，如果沒有則使用預設值
    default_icode = 'K00016'
    return CommunityProfile.first&.asus_icode || default_icode
  rescue StandardError => e
    log("無法取得 icode 從 CommunityProfile: #{e.message}", :error)
    default_icode
  end

  def get_key_from_community_profile
    # 從 CommunityProfile 模型取得 key，如果沒有則使用預設值
    default_key = 'K00016yFjdKGNeVF'
    return CommunityProfile.first&.asus_key || default_key
  rescue StandardError => e
    log("無法取得 key 從 CommunityProfile: #{e.message}", :error)
    default_key
  end

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
