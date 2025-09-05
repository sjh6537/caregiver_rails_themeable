puts "=== 檢查社區資料 ==="
puts "社區數量: #{Community.count}"
Community.all.each { |c| puts "- #{c.name} (ID: #{c.id})" }

puts "\n=== 檢查使用者資料 ==="
puts "使用者數量: #{User.count}"
User.limit(3).each { |u| puts "- #{u.name} (社區ID: #{u.community_id})" }

puts "\n=== 檢查健身器材類型 ==="
puts "器材類型數量: #{FitnessDeviceType.count}"
FitnessDeviceType.all.each { |t| puts "- #{t.name}" }

puts "\n=== 嘗試建立測試健身器材 ==="
begin
  device = FitnessDevice.new(
    name: "測試器材",
    fitness_device_type: FitnessDeviceType.first,
    community: Community.first,
    serial_number: "TEST001"
  )
  puts "驗證結果: #{device.valid?}"
  unless device.valid?
    puts "錯誤: #{device.errors.full_messages}"
  end
rescue => e
  puts "錯誤: #{e.message}"
end
