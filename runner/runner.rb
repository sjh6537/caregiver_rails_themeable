# runner.rb
# 首先引入相關依賴
require 'rubygems'
require 'bundler/setup'
# 引入 sidekiq
require 'sidekiq'
# 然後引入您的類別
require File.expand_path('../config/environment', __dir__)
require_relative '../app/services/health_report_crawler'

# 創建一個實例
crawler = HealthReportCrawler.new

ICODE = 'K00016' unless defined?(ICODE)

# 使用 send 方法執行私有方法
key = 'K00016yFjdKGNeVF'
raw_string = 'A131640688,S124964043'
puts "身份證: #{raw_string}"
result = crawler.send(:aes_cbc_encrypt, key, raw_string)
puts "結果: #{result}"

# 從Asus的server爬所有使用者的量測資料
current_date = DateTime.now.strftime('%Y-%m-%d')
start_time = "#{current_date} 00:00:00"
end_time = "#{current_date} 23:59:59"

puts "開始時間: #{start_time}"
puts "結束時間: #{end_time}"

# Constants should be defined or imported from elsewhere

vital_signs = crawler.send(:get_vital_signs, ICODE, result, start_time, end_time)
puts "量測資料: #{vital_signs}"
user_info = crawler.send(:aes_cbc_decrypt, key, vital_signs['data'])
data_dict = crawler.send(:extract_data, user_info)

puts "使用者資料: #{user_info}"
puts "量測資料: #{data_dict}"
