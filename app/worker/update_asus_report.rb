#  UpdateAsusReport 類別負責更新所有使用者的健康報告資訊
class UpdateAsusReport
  include Sidekiq::Worker # 將此類別標記為 Sidekiq 工作者，可以進行背景任務處理
  sidekiq_options retry: false # 設定此任務失敗時不進行重試

  # 執行更新所有用戶健康報告的主要方法
  # @return [void]
  def perform
    # 處理 SN 為 CM001 中庄和 CM004 花壇的社區
    target_sns = %w[CM001 CM004]
    communities = Community.where(sn: target_sns)
    if communities.empty?
      Rails.logger.info "找不到 SN 為 #{target_sns.join(', ')} 的社區，結束更新任務"
      return
    end

    communities.each do |community|
      profile = community.community_profile
      unless profile&.asus_icode.present? && profile&.asus_key.present?
        Rails.logger.info "社區 #{community.name} (SN: #{community.sn}) 未設定 asus_icode 或 asus_key，跳過"
        next
      end

      begin
        Rails.logger.info "處理社區: #{community.name} (SN: #{community.sn})"

        crawler = HealthReportCrawler.new(icode: profile.asus_icode, key: profile.asus_key)
        result = crawler.fetch_health_data
        crawler.process_health_data(result) if result.present?
        Rails.logger.info "成功更新社區 #{community.name} 的健康報告資料"
      rescue StandardError => e
        Rails.logger.error "處理社區 #{community.name} 健康報告時發生錯誤: #{e.message}"
      end
    end
  end
end
