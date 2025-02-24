class Admin::HealthController < ApplicationController
  protect_from_forgery with: :null_session # 關閉 CSRF 驗證
  before_action :restrict_access_to_localhost, only: [:idcard_list] # 限制只能本機存取
  include LineHelper

  def restrict_access_to_localhost
    Rails.logger.info "Remote IP: #{request.remote_ip}"
    Rails.logger.info "Local? #{request.local?}"

    return if request.local? || ['127.0.0.1', '::1'].include?(request.remote_ip)

    head :forbidden
  end

  def idcard_list
    users = User.where.not(id_card: nil)
    list = users.map do |user|
      user.id_card
    end
    render json: { status: 'success', datas: list }, status: :ok
  end

  def measurements
    data = JSON.parse(request.body.read)

    list = data.map do |item|
      {
        id_card: item.dig('User_id'),
        temperature: item.dig('TP', 'temperature'),
        sbp: item.dig('BP', 'sbp'),
        dbp: item.dig('BP', 'dbp'),
        hb_bp: item.dig('BP', 'hb'), # 注意: hb 可能重複，建議改名
        bs: item.dig('BS', 'bs'),
        hg: item.dig('BS', 'hg'),
        hct: item.dig('BS', 'hct'),
        oxygen: item.dig('OX', 'oxygen'),
        hb_ox: item.dig('OX', 'hb'), # 注意: hb 可能重複，建議改名
        hb_hb: item.dig('HB', 'hb'), # 注意: hb 可能重複，建議改名
        bw: item.dig('BW', 'bw'),
        bmi: item.dig('BW', 'bmi'),
        tc: item.dig('TC', 'tc'),
        ua: item.dig('UA', 'ua'),
        ohb: item.dig('OHB', 'ohb')
      }
    end

    list.each do |item|
      item[:user_id]
      id_card = item[:id_card]
      next unless !id_card.nil? || !id_card.empty?

      user = User.find_by(id_card: id_card)
      next if user.nil?

      # 初始化 text 變數
      text = ''
      # 發送訊息
      text += "體溫: #{item[:temperature]}\n"
      text += "收縮壓: #{item[:sbp]}\n"
      text += "舒張壓: #{item[:dbp]}\n"
      text += "脈搏: #{item[:hb_bp]}\n"
      text += "血糖: #{item[:bs]}\n"
      text += "血紅素: #{item[:hg]}\n"
      text += "血球容積比: #{item[:hct]}\n"
      text += "血氧濃度: #{item[:oxygen]}\n"
      # text += "脈搏: #{item[:hb_ox]}\n"
      # text += "脈搏: #{item[:hb_hb]}\n"
      text += "體重: #{item[:bw]}\n"
      text += "BMI: #{item[:bmi]}\n"
      text += "總膽固醇: #{item[:tc]}\n"
      text += "尿酸: #{item[:ua]}\n"
      text += "酮體: #{item[:ohb]}\n"

      user_text = "Hi , 你有一份健康報告 : \n"
      user_text += text
      message_push(user.account, user_text)

      caregiver = user.caregivers.first
      unless caregiver.nil?
        caregiver_text = "Hi , 你的照護者「#{user.name}」有一份健康報告 : \n"
        caregiver_text += text
        message_push(caregiver.account, caregiver_text)
      end

      # 寫入量測資料
      report = user.health_reports.new(bmi: item[:bmi], heart_rate: item[:hb_bp],
                                       blood_pressure1: item[:sbp], blood_pressure2: item[:dbp], blood_sugar: item[:bs], temperature: item[:temperature], blood_oxygen: item[:oxygen], weight: item[:bw], total_cholesterol: item[:tc], uric_acid: item[:ua], hemoglobin: item[:hg], hematocrit: item[:hct], ketones: item[:ohb])
      report.save
    end
    render json: { status: 'success', message: 'Message sent successfully' }, status: :ok
  rescue JSON::ParserError
    render json: { error: 'Invalid JSON data' }, status: :bad_request
  rescue StandardError => e
    render json: { error: "An error occurred: #{e.message}" }, status: :internal_server_error
    Rails.logger.error("Error processing data: #{e.message}")
  end

  # 原森林小站取得之資料
  def send_message
    uid = params[:uid]
    params[:phone]
    bmi = params[:bmi]
    heart_rate = params[:heart_rate]
    blood_pressure1 = params[:blood_pressure1]
    blood_pressure2 = params[:blood_pressure2]
    blood_sugar = params[:blood_sugar]
    temperature = params[:temperature]
    blood_oxygen = params[:blood_oxygen]
    body_fat = params[:body_fat]

    if !params[:uid].present?
      render json: { status: 'error', message: 'error parameter' }, status: :ok
    else
      # user = User.where("account == ? AND phone == ?", uid , phone)
      user = User.find(uid.to_i)
      if user.nil?
        render json: { status: 'error', message: 'error user' }, status: :ok
      else

        text = "BMI: #{bmi}\n"
        text += "心跳: #{heart_rate}\n"
        text += "收縮壓: #{blood_pressure1}\n"
        text += "舒張壓: #{blood_pressure2}\n"
        text += "血糖: #{blood_sugar}\n"
        text += "體溫: #{temperature}\n"
        text += "血氧: #{blood_oxygen}\n"
        text += "體脂: #{body_fat}"

        user_text = "Hi , 你有一份健康報告 : \n"
        user_text += text
        message_push(user.account, user_text)

        caregiver = user.caregivers.first
        unless caregiver.nil?
          caregiver_text = "Hi , 你的照護者「#{user.name}」有一份健康報告 : \n"
          caregiver_text += text
          message_push(caregiver.account, caregiver_text)
        end

        report = user.health_reports.new(bmi: bmi, heart_rate: heart_rate, blood_pressure1: blood_pressure1,
                                         blood_pressure2: blood_pressure2, blood_sugar: blood_sugar, temperature: temperature, blood_oxygen: blood_oxygen, body_fat: body_fat)
        report.save

        render json: { status: 'success', message: 'Message sent successfully' }, status: :ok
      end
    end
  end
end
