# UpdateHealthReport 類別負責更新所有使用者的健康報告資訊
class UpdateHealthReport
  include Sidekiq::Worker # 將此類別標記為 Sidekiq 工作者，可以進行背景任務處理
  sidekiq_options retry: false # 設定此任務失敗時不進行重試

  # 執行更新所有用戶健康報告的主要方法
  # @return [void]
  def perform
    # 找出所有有設定 asus_icode 的社區
    Community.where(enable: true).each do |community|
      profile = community.community_profile
      next unless profile.asus_icode.present? && profile.asus_key.present?

      begin
        Rails.logger.info "處理社區: #{community.name} (SN: #{community.sn})"

        # 建立健康資料爬蟲實例
        crawler = HealthReportCrawler.new(icode: profile.asus_icode, key: profile.asus_key)

        # 取得今日資料
        result = crawler.fetch_health_data

        # 處理取得的健康資料
        crawler.process_health_data(result) if result.present?

        Rails.logger.info "成功更新社區 #{community.name} 的健康報告資料"
      rescue StandardError => e
        Rails.logger.error "處理社區 #{community.name} 健康報告時發生錯誤: #{e.message}"
      end
    end
  end
end
