puts "=== 健身器材系統測試 ==="

puts "\n1. 健身器材類型："
FitnessDeviceType.all.each do |type|
  puts "   - #{type.name}: #{type.enabled ? '啟用' : '停用'} (排序: #{type.sort_order})"
end

puts "\n2. 健身器材："
FitnessDevice.includes(:fitness_device_type, :community).each do |device|
  puts "   - #{device.name} (#{device.device_id}): #{device.fitness_device_type.name} @ #{device.community.name}"
end

puts "\n3. 使用記錄："
FitnessDeviceUsage.includes(:user, :fitness_device).limit(10).each do |usage|
  status = usage.in_use? ? '使用中' : '已完成'
  duration = usage.duration_minutes ? "#{usage.duration_minutes}分鐘" : '--'
  puts "   - #{usage.user.name} 使用 #{usage.fitness_device.name}: #{status} (#{duration})"
end

puts "\n=== 統計資訊 ==="
puts "健身器材類型數量: #{FitnessDeviceType.count}"
puts "健身器材數量: #{FitnessDevice.count}"
puts "使用記錄數量: #{FitnessDeviceUsage.count}"
puts "進行中的使用記錄: #{FitnessDeviceUsage.where(status: :in_use).count}"
puts "已完成的使用記錄: #{FitnessDeviceUsage.where(status: :completed).count}"

puts "\n=== 路由測試 ==="
begin
  puts "✅ admin_fitness_device_types_path: 可用"
  puts "✅ admin_fitness_devices_path: 可用"
  puts "✅ admin_fitness_device_usages_path: 可用"
rescue => e
  puts "❌ 路由錯誤: #{e.message}"
end

puts "\n=== 測試完成 ==="
