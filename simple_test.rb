type = FitnessDeviceType.new(name: '跑步機')
puts "Valid? #{type.valid?}"
if !type.valid?
  puts "Errors: #{type.errors.full_messages}"
end
puts "Creating..."
type.save!
puts "Success: #{type.id}"
