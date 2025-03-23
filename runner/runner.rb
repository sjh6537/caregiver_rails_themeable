# runner.rb
# 首先引入相關依賴
require 'rubygems'
require 'bundler/setup'
# 引入 sidekiq
require 'sidekiq'
# 然後引入您的類別
require_relative '../app/worker/health_report_crawler'

# 創建一個實例
crawler = HealthReportCrawler.new

# 使用 send 方法執行私有方法
key = 'K00016yFjdKGNeVF'
raw_string = 'A131640688,S124964043'
result = crawler.send(:aes_cbc_encrypt, key, raw_string)
puts "結果: #{result}"

# 從Asus的server爬所有使用者的量測資料
current_date = DateTime.now.strftime('%Y-%m-%d')
start_time = "#{current_date} 00:00:00"
end_time = "#{current_date} 23:59:59"

# Constants should be defined or imported from elsewhere
ICODE = 'K00016' unless defined?(ICODE)
encrypted_id = 'K00016yFjdKGNeVF' # Define this value
KEY = key unless defined?(KEY) # Use the key defined above

vital_signs = crawler.send(:get_vital_signs, ICODE, encrypted_id, start_time, end_time)
user_info = crawler.send(:aes_cbc_decrypt, KEY, vital_signs['data'])
data_dict = crawler.send(:extract_data, user_info)

puts "使用者資料: #{user_info}"
puts "量測資料: #{data_dict}"
