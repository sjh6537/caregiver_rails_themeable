# 建立健身器材類型（這些已經存在，所以會略過）
types_data = [
  { name: '跑步機', description: '有氧運動設備', icon: 'fas fa-running', icon_color: '#28a745', enabled: true, sort_order: 1 },
  { name: '飛輪車', description: '室內單車訓練', icon: 'fas fa-bicycle', icon_color: '#007bff', enabled: true, sort_order: 2 },
  { name: '重量訓練機', description: '肌力訓練設備', icon: 'fas fa-dumbbell', icon_color: '#dc3545', enabled: true, sort_order: 3 },
  { name: '橢圓機', description: '全身有氧運動', icon: 'fas fa-circle-notch', icon_color: '#ffc107', enabled: true, sort_order: 4 },
  { name: '划船機', description: '全身協調訓練', icon: 'fas fa-water', icon_color: '#17a2b8', enabled: true, sort_order: 5 }
]

types_data.each do |type_data|
  type = FitnessDeviceType.find_or_create_by(name: type_data[:name]) do |t|
    t.description = type_data[:description]
    t.icon = type_data[:icon]
    t.icon_color = type_data[:icon_color]
    t.enabled = type_data[:enabled]
    t.sort_order = type_data[:sort_order]
  end
end

# 取得社區和器材類型
communities = Community.all
device_types = FitnessDeviceType.all

if communities.empty?
  puts "錯誤：沒有找到社區資料，請先建立社區"
  exit
end

if device_types.empty?
  puts "錯誤：沒有找到器材類型，請先建立器材類型"
  exit
end

puts "開始建立健身器材..."

# 建立 20 筆健身器材
20.times do |i|
  community = communities.sample
  device_type = device_types.sample
  
  device = FitnessDevice.create!(
    device_id: "DEV#{Time.current.strftime('%Y%m%d')}#{sprintf('%03d', i + 1)}",
    name: "#{device_type.name}-#{sprintf('%03d', i + 1)}",
    fitness_device_type: device_type,
    community: community,
    serial_number: "SN#{Time.current.strftime('%Y%m%d')}#{sprintf('%03d', i + 1)}",
    brand: ['TechGym', 'FitMax', 'PowerFit', 'EliteGym', 'ProHealth'].sample,
    model: "Model-#{('A'..'Z').to_a.sample}#{rand(100..999)}",
    location: ['健身房一樓', '健身房二樓', '社區中心', '戶外區域', '多功能教室'].sample,
    mac_address: Array.new(6){"%02x" % rand(256)}.join(":"),
    ip_address: "192.168.1.#{rand(10..250)}",
    status: ['normal', 'maintenance', 'normal', 'normal'].sample, # 大部分為正常狀態
    enabled: [true, false, true, true, true].sample, # 大部分為啟用
    sort_order: i + 1,
    notes: ["設備運作正常", "定期保養中", "新購入設備", ""].sample
  )
  
  puts "建立設備: #{device.name} (#{device.community.name})"
end

puts "健身器材建立完成！"

# 取得使用者和設備
users = User.all
devices = FitnessDevice.all

if users.empty?
  puts "錯誤：沒有找到使用者資料"
  exit
end

puts "開始建立使用記錄..."

# 建立 50 筆使用記錄
50.times do |i|
  device = devices.sample
  # 只選擇同一社區的使用者
  community_users = users.select { |u| u.community_id == device.community_id }
  
  if community_users.empty?
    puts "警告：設備 #{device.name} 的社區沒有使用者，跳過"
    next
  end
  
  user = community_users.sample
  
  # 隨機產生開始時間（過去 30 天內）
  start_time = rand(30.days).seconds.ago
  
  # 隨機決定是否已結束使用
  is_ended = [true, false, true, true].sample # 大部分已結束
  
  end_time = nil
  
  if is_ended
    # 已結束的使用記錄，隨機產生 10分鐘到 2小時的使用時長
    duration_minutes = rand(10..120)
    end_time = start_time + duration_minutes.minutes
  end
  
  usage = FitnessDeviceUsage.create!(
    fitness_device: device,
    user: user,
    start_time: start_time,
    end_time: end_time,
    status: is_ended ? "completed" : "in_use",
    notes: [
      "正常使用",
      "有氧運動訓練",
      "肌力訓練",
      "復健使用",
      "初學者體驗",
      ""
    ].sample
  )
  
  status = is_ended ? "已結束" : "使用中"
  puts "建立使用記錄 #{i + 1}: #{user.name} 使用 #{device.name} (#{status})"
end

puts "使用記錄建立完成！"

# 統計資訊
puts "\n=== 統計資訊 ==="
puts "健身器材類型數量: #{FitnessDeviceType.count}"
puts "健身器材數量: #{FitnessDevice.count}"
puts "使用記錄數量: #{FitnessDeviceUsage.count}"
puts "進行中的使用記錄: #{FitnessDeviceUsage.where(end_time: nil).count}"
