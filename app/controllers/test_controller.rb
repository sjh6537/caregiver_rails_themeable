class TestController < ApplicationController
  include LineHelper

  # 設定跳過驗證（僅用於測試環境）
  skip_before_action :verify_authenticity_token, only: %i[test_line_push test_health_report]

  # 一、LINE 推播測試功能
  def test_line_push
    id_card = params[:id_card]
    message = params[:message] || '這是一則測試推播訊息！'

    # 找出對應的使用者
    user = User.find_by(id_card: id_card)

    if user.nil?
      render json: { status: 'error', message: '找不到此身份證號碼的使用者！' }, status: :not_found
      return
    end

    # 建立訊息物件
    line_message = {
      type: 'text',
      text: message
    }
    community_profile = user.community.community_profile

    line_client = Line::Bot::Client.new do |config|
      config.channel_id = community_profile.line_message_api_channel_id
      config.channel_secret = community_profile.line_message_api_channel_secret
      config.channel_token = community_profile.line_message_api_channel_token
    end

    # 推播訊息
    response = line_client.push_message(user.account, line_message)

    if response.code.to_i == 200
      render json: { status: 'success', message: '推播訊息已成功發送！' }, status: :ok
    else
      render json: {
        status: 'error',
        message: '推播訊息發送失敗！',
        details: response.body
      }, status: :unprocessable_entity
    end
  end

  # 二、測試 HealthReportCrawler 功能
  def test_health_report
    icode = params[:icode]
    key = params[:key]

    # 檢查參數是否存在
    unless icode.present? && key.present?
      render json: {
        status: 'error',
        message: '缺少必要參數！請提供 icode 和 key'
      }, status: :bad_request
      return
    end

    # 檢查社區設定檔是否存在
    community_profile = CommunityProfile.find_by(icode: icode)
    unless community_profile
      render json: {
        status: 'error',
        message: '找不到對應的社區設定檔！請確認 icode 是否正確'
      }, status: :not_found
      return
    end

    # 建立測試爬蟲實例並執行健康數據抓取
    crawler = TestHealthReportCrawler.new(icode: icode, key: key)
    result = crawler.fetch_and_process_health_data

    render json: {
      status: 'success',
      message: '健康報告資料抓取成功！',
      result: result
    }, status: :ok
  rescue HealthReportCrawler::APIError => e
    render json: {
      status: 'error',
      message: '抓取健康報告時發生 API 錯誤！',
      error: e.message
    }, status: :bad_gateway
  rescue HealthReportCrawler::EncryptionError => e
    render json: {
      status: 'error',
      message: '資料加解密過程發生錯誤！',
      error: e.message
    }, status: :internal_server_error
  rescue StandardError => e
    render json: {
      status: 'error',
      message: '發生未預期的錯誤！',
      error: e.message,
      backtrace: e.backtrace.take(10)
    }, status: :internal_server_error
  end
end
