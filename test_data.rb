# 建立測試健身器材類型
type = FitnessDeviceType.create!(
  name: '跑步機',
  description: '用於有氧運動的設備',
  icon: 'fas fa-running',
  icon_color: '#00ff00',
  enabled: true,
  sort_order: 1
)
puts "建立成功: #{type.id} - #{type.name}"

type2 = FitnessDeviceType.create!(
  name: '重量訓練器',
  description: '用於肌力訓練的設備',
  icon: 'fas fa-dumbbell',
  icon_color: '#ff0000',
  enabled: true,
  sort_order: 2
)
puts "建立成功: #{type2.id} - #{type2.name}"

puts "總共有 #{FitnessDeviceType.count} 個健身器材類型"
