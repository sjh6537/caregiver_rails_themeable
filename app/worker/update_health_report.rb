# UpdateHealthReport 類別負責更新所有使用者的健康報告資訊
# 此工作由 Sidekiq 排程器每分鐘執行一次 (詳見 config/sidekiq.yml)
# 主要用途：更新所有用戶的 nhi_id 欄位為目前的時間戳記，用於健康報告狀態追蹤
class UpdateHealthReport
  include Sidekiq::Worker # 將此類別標記為 Sidekiq 工作者，可以進行背景任務處理
  sidekiq_options retry: false # 設定此任務失敗時不進行重試

  # 執行更新所有用戶健康報告的主要方法
  # @return [void]
  def perform
    User.all.map do |user|
      # 取得目前時間（包含毫秒）
      current_time = Time.now
      milliseconds = (current_time.to_f * 1000).to_i % 1000
      formatted_time = "#{current_time.strftime('%Y-%m-%d %H:%M:%S')}"

      # 顯示處理進度並記錄時間
      puts "Processing user: #{user.id}, at time: #{formatted_time}"

      # 更新使用者的 nhi_id 欄位為格式化後的時間
      # 注意：此處假設 nhi_id 欄位用於暫時儲存時間戳記，實際應用可能需要調整
      user.update(nhi_id: formatted_time)
    end
  end
end
