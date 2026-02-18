# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 創建一個社區數據
community = Community.find_by(sn: 'CM001')
if community
  puts "Community with SN 'CM001' already exists"
else
  community = Community.create!(
    sn: 'CM001',
    name: '中庄社區',
    name_eng: 'padifield',
    description: '稻相顧 中庄社區',
    enable: true,
    sort: 1,
    logo: '/assets/images/community/cm001_logo.png',
    status: 'active',
    address: '503彰化縣花壇鄉車路街196巷33號',
    phone: '0920805071',
    email: 'happycommunity@example.com',
    contact_name: '王管理',
    contact_phone: '0912-345-678',
    contact_email: 'manager@example.com',
    contact_title: '社區主任',
    note: '新建社區',
    comment: '2025年新建立'
  )
  puts "Created a new community with SN 'CM001'"

  # 獲取社區相關的 profile，可能是自動創建的空記錄
  community_profile = CommunityProfile.find_by(community_id: community.id)

  # 更新已存在的 profile 或創建新的 profile
  if community_profile
    community_profile.update!(
      line_at_url: 'https://line.me/R/ti/p/%40916lsfmg',
      line_login_channel_id: '2006848648',
      line_login_channel_secret: '45c7c39f0fac242335b05d421af03b0e',
      line_login_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_liff_id: '2004751931-1jrD53LP',
      line_liff_url: 'https://liff.line.me/2004751931-POn4oBxp',
      line_message_api_channel_id: '2006848439',
      line_message_api_channel_secret: 'f998cf3afa2fefbdd120e98a763eb5a5',
      line_message_api_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_message_api_channel_token: 'iFRLruIPxX9DybWtIZmqe4ChcbJeT9kFNsBEvsA0XrOxBBbgg1VmpVIr3WOfp4/n47TYrYhxbMoFbkoedglXIR6zQpPHyRHQvjufI+dXrbpwOWrVy1vYkUW20cIKhrA1LatLJz+ExHCXBqM1MgjNNgdB04t89/1O/w1cDnyilFU=',
      google_map_key: 'AIzaSyAIrjnyChM8LHj1xInbMWFlGye5LxFaatU',
      note: '初始設定',
      comment: '2025年設定'
    )
    puts "Updated existing community profile for community '#{community.name}'"
  else
    CommunityProfile.create!(
      community_id: community.id,
      line_at_url: 'https://line.me/R/ti/p/%40916lsfmg',
      line_login_channel_id: '2006848648',
      line_login_channel_secret: '45c7c39f0fac242335b05d421af03b0e',
      line_login_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_liff_id: '2004751931-1jrD53LP',
      line_liff_url: 'https://liff.line.me/2004751931-POn4oBxp',
      line_message_api_channel_id: '2006848439',
      line_message_api_channel_secret: 'f998cf3afa2fefbdd120e98a763eb5a5',
      line_message_api_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_message_api_channel_token: 'iFRLruIPxX9DybWtIZmqe4ChcbJeT9kFNsBEvsA0XrOxBBbgg1VmpVIr3WOfp4/n47TYrYhxbMoFbkoedglXIR6zQpPHyRHQvjufI+dXrbpwOWrVy1vYkUW20cIKhrA1LatLJz+ExHCXBqM1MgjNNgdB04t89/1O/w1cDnyilFU=',
      google_map_key: 'AIzaSyAIrjnyChM8LHj1xInbMWFlGye5LxFaatU',
      note: '初始設定',
      comment: '2025年設定'
    )
    puts "Created a new community profile for community '#{community.name}'"
  end
end

Community.find_each do |community|
  community.update(
    theme_key: community.theme_key.presence || "valex",
    layout_preset: community.layout_preset.presence || "valex",
    theme_settings: community.theme_settings.presence || Community::DEFAULT_THEME_SETTINGS
  )
end

# 找到 user id 是 1 的資料
# user = User.find_by(id: 1)

# # 宣告一個變數來存儲新建立的使用者
# new_user = nil

# if user
#   new_user = user
# else
#   # 如果找不到 user id 是 1 的資料，創建一個新的 user
#   new_user = User.create!(
#     id: 1,
#     community_id: community.id, # 將user關聯到新創建的社區
#     name: '洪晨峰',
#     account: 'Ua435ab1c9143f1197062ef996cda2916',
#     oauth_token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVWE0MzVhYjFjOTE0M2YxMTk3MDYyZWY5OTZjZGEyOTE2IiwiYXVkIjoiMjAwNTQ5NTQ1MSIsImV4cCI6MTczOTg2NTkyNSwiaWF0IjoxNzM5ODYyMzI1LCJhbXIiOlsibGluZWF1dG9sb2dpbiJdLCJuYW1lIjoiY2hlbmZ1biIsInBpY3R1cmUiOiJodHRwczovL3Byb2ZpbGUubGluZS1zY2RuLm5ldC8waHlNV3NKdUZpSm1KcUNqZW1KUzFaTlZaUEtBOGRKQ0FxRW1WdEJCb0NmRkJCUDJneVVUZzVCMHdQS0ZSUE9HSThCRGhyQVU1ZExBVlAifQ._aE0kzk-Nd6MWpdXz3aWcMhB9D9FKb3NPbFM5XZaLG8',
#     email: 'chenfun_b51@hotmai.com',
#     phone: '0938692600',
#     id_card: 'N125571815',
#     password: '123456789',
#     created_at: Time.now
#   )
#   puts 'Created a new user with id 1'
# end

# # 找到 user_profiles 表格中的相關資料
# user_profile = User::Profile.find_by(user_id: new_user.id)

# if user_profile
#   puts "User profile already exists for user id #{new_user.id}"
# else
#   # 創建新的 user_profile
#   User::Profile.create!(
#     id: 1,
#     user_id: new_user.id,
#     line_uid: 'Ua435ab1c9143f1197062ef996cda2916',
#     line_token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVWE0MzVhYjFjOTE0M2YxMTk3MDYyZWY5OTZjZGEyOTE2IiwiYXVkIjoiMjAwNTQ5NTQ1MSIsImV4cCI6MTczOTg2NTkyNSwiaWF0IjoxNzM5ODYyMzI1LCJhbXIiOlsibGluZWF1dG9sb2dpbiJdLCJuYW1lIjoiY2hlbmZ1biIsInBpY3R1cmUiOiJodHRwczovL3Byb2ZpbGUubGluZS1zY2RuLm5ldC8waHlNV3NKdUZpSm1KcUNqZW1KUzFaTlZaUEtBOGRKQ0FxRW1WdEJCb0NmRkJCUDJneVVUZzVCMHdQS0ZSUE9HSThCRGhyQVU1ZExBVlAifQ._aE0kzk-Nd6MWpdXz3aWcMhB9D9FKb3NPbFM5XZaLG8',
#     line_name: 'chenfun',
#     line_image: 'https://profile.line-scdn.net/0hyMWsJuFiJmJqCjemJS1ZNVZPKA8dJCAqEmVtBBoCfFBBP2gyUTg5B0wPKFRPOGI8BDhrAU5dLAVP'
#   )
#   puts "Created a new user profile for user id #{new_user.id}"
# end

# 創建第二社區 浚葦社區
community2 = Community.find_by(sn: 'CM002')
if community2
  puts "Community with SN 'CM002' already exists"
else
  community2 = Community.create!(
    sn: 'CM002',
    name: '浚葦社區',
    name_eng: 'weiwei',
    description: '浚葦社區',
    enable: true,
    sort: 2,
    logo: '/assets/images/community/cm002_logo.png',
    status: 'active',
    address: '503彰化縣花壇鄉車路街196巷33號',
    phone: '0920805071',
    email: 'chenfun_b51@hotmail.com',
    contact_name: '洪浚葦',
    contact_phone: '0912-345-678',
    contact_email: '',
    contact_title: '社區主任',
    note: '新建社區',
    comment: '2025年新建立'
  )
  puts "Created a new community with SN 'CM002'"

  # 獲取社區相關的 profile，可能是自動創建的空記錄
  community_profile = CommunityProfile.find_by(community_id: community2.id)

  # 更新已存在的 profile 或創建新的 profile
  if community_profile
    community_profile.update!(
      line_at_url: 'https://line.me/R/ti/p/%40519dlpmy',
      line_login_channel_id: '2007069569',
      line_login_channel_secret: '2b1bf5bcea68cb1598a3f29ede6eb8cd',
      line_login_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_liff_id: '2004751931-1jrD53LP',
      line_liff_url: 'https://liff.line.me/2004751931-POn4oBxp',
      line_message_api_channel_id: '1656710054',
      line_message_api_channel_secret: '4db1f73ad5dec618f70fee894b3f34e0',
      line_message_api_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_message_api_channel_token: 'ZwnHA+vFeSknDHE1KjgYByCyTmUIeJdZhsk+nU1dQyDwUikLI9QlzwkbDWQSQI0FY8YTcfDBo44olokrFAlPCYpThFoKxJdVwA0JoZYFTy0nyXhVstii9b9/LQ5oyb17sW5jVNo576/16u8HknDIGQdB04t89/1O/w1cDnyilFU=',
      google_map_key: 'AIzaSyAIrjnyChM8LHj1xInbMWFlGye5LxFaatU',
      note: '初始設定',
      comment: '2025年設定'
    )
    puts "Updated existing community profile for community '#{community2.name}'"
  else
    CommunityProfile.create!(
      community_id: community2.id,
      line_at_url: 'https://line.me/R/ti/p/%40519dlpmy',
      line_login_channel_id: '2007069569',
      line_login_channel_secret: '2b1bf5bcea68cb1598a3f29ede6eb8cd',
      line_login_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_liff_id: '2004751931-1jrD53LP',
      line_liff_url: 'https://liff.line.me/2004751931-POn4oBxp',
      line_message_api_channel_id: '1656710054',
      line_message_api_channel_secret: '4db1f73ad5dec618f70fee894b3f34e0',
      line_message_api_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_message_api_channel_token: 'ZwnHA+vFeSknDHE1KjgYByCyTmUIeJdZhsk+nU1dQyDwUikLI9QlzwkbDWQSQI0FY8YTcfDBo44olokrFAlPCYpThFoKxJdVwA0JoZYFTy0nyXhVstii9b9/LQ5oyb17sW5jVNo576/16u8HknDIGQdB04t89/1O/w1cDnyilFU=',
      google_map_key: 'AIzaSyAIrjnyChM8LHj1xInbMWFlGye5LxFaatU',
      note: '初始設定',
      comment: '2025年設定'
    )
    puts "Created a new community profile for community '#{community2.name}'"
  end

end

community3 = Community.find_by(sn: 'CM003')
if community3
  puts "Community with SN 'CM003' already exists"
else
  community3 = Community.create!(
    sn: 'CM003',
    name: '塵封小站',
    name_eng: 'chenfeng',
    description: '塵封小站',
    enable: true,
    sort: 2,
    logo: '/assets/images/community/cm003_logo.png',
    status: 'active',
    address: '709台南市南區建國路二段',
    phone: '0921345678',
    email: 'chenfun123@hotmail.com',
    contact_name: '江塵封',
    contact_phone: '0912345678',
    contact_email: '',
    contact_title: '社區主任',
    note: '新建社區',
    comment: '2024年新建立'
  )
  puts "Created a new community with SN 'CM003'"

  # 獲取社區相關的 profile，可能是自動創建的空記錄
  community_profile = CommunityProfile.find_by(community_id: community3.id)

  # 更新已存在的 profile 或創建新的 profile
  if community_profile
    community_profile.update!(
      line_at_url: 'https://line.me/R/ti/p/%40724kzqto',
      line_login_channel_id: '2007109675',
      line_login_channel_secret: '631fb5014d30cbece649d3bc4ad178a6',
      line_login_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_liff_id: '2004751931-1jrD53LP',
      line_liff_url: 'https://liff.line.me/2004751931-POn4oBxp',
      line_message_api_channel_id: '2007109659',
      line_message_api_channel_secret: '9eb120c2498a3afe1acba0bb053996d5',
      line_message_api_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_message_api_channel_token: 'vxamUBKGP2n8295DaJgAId/mSCoGMyg6+Wn2yeYE76bCuu4MgeHZzLK54WO1si8I+PfWUIMEs2X1LMmqK2cuJlNJEOHhTcZ7Ro7y4o6qlTZIKOenJsy6WECVMApvPbYfV/GyIabJExhERL/8Ypeq2gdB04t89/1O/w1cDnyilFU=',
      google_map_key: 'AIzaSyAIrjnyChM8LHj1xInbMWFlGye5LxFaatU',
      note: '初始設定',
      comment: '2025年設定'
    )
    puts "Updated existing community profile for community '#{community3.name}'"
  else
    CommunityProfile.create!(
      community_id: community3.id,
      line_at_url: 'https://line.me/R/ti/p/%40724kzqto',
      line_login_channel_id: '2007109675',
      line_login_channel_secret: '631fb5014d30cbece649d3bc4ad178a6',
      line_login_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_liff_id: '2004751931-1jrD53LP',
      line_liff_url: 'https://liff.line.me/2004751931-POn4oBxp',
      line_message_api_channel_id: '2007109659',
      line_message_api_channel_secret: '9eb120c2498a3afe1acba0bb053996d5',
      line_message_api_channel_callback_url: 'https://padifield.hopto.org/callback',
      line_message_api_channel_token: 'vxamUBKGP2n8295DaJgAId/mSCoGMyg6+Wn2yeYE76bCuu4MgeHZzLK54WO1si8I+PfWUIMEs2X1LMmqK2cuJlNJEOHhTcZ7Ro7y4o6qlTZIKOenJsy6WECVMApvPbYfV/GyIabJExhERL/8Ypeq2gdB04t89/1O/w1cDnyilFU=',
      google_map_key: 'AIzaSyAIrjnyChM8LHj1xInbMWFlGye5LxFaatU',
      note: '初始設定',
      comment: '2025年設定'
    )
    puts "Created a new community profile for community '#{community3.name}'"
  end

end

# 建立管理者帳號
admin1 = Admin.find_by(account: 'chenfun')
admin2 = Admin.find_by(account: 'leo')
if admin1.nil?
  Admin.create!(account: 'chenfun', password: '123456', name: 'chenfun', email: 'chenfun168@gmail.com')
  puts "Created admin account 'chenfun'"
end
if admin2.nil?
  Admin.create!(account: 'leo', password: '123456', name: 'leo', email: 'B8808040@gmail.com') if admin1.nil?
  puts "Created admin account 'leo'"
end

# 從 fitness_devices_type, 與 fitness_devices 資料抓出來並建立
fitness_devices_type = FitnessDeviceType.find_by(name: '被動式')
if fitness_devices_type.nil?
  fitness_devices_type = FitnessDeviceType.create!(
    name: '被動式',
    description: '被動式'
  )
  puts "Created fitness device type '#{fitness_devices_type.name}'"
end

fitness_devices = FitnessDevice.find_by(device_id: 'FT-001')
if fitness_devices.nil?
  fitness_devices = FitnessDevice.create!(
    community_id: community2.id,
    device_id: 'FT-001',
    name: '垂直律動機',
    brand: 'Bakkarat',
    fitness_device_type_id: fitness_devices_type.id
  )
  puts "Created fitness device '#{fitness_devices.name}'"


# Cared Facility Types
CaredFacilityType.create!([
  { name: 'CO2' },
  { name: 'GAS' },
  { name: 'CO2_GAS' },
  { name: 'Fire' },
  { name: 'Camera' },
  { name: 'EmergencyButton' }
])

# Cared Facility Event Types
CaredFacilityEventType.create!([
  { name: 'KeepAlive' },
  { name: 'Warning' },
  { name: 'Urgent' },
])

# Cared Facility (照護設備)
CaredFacility.create!([
  { name: 'CO2偵測器1', cared_user_info_id: 2, cared_facility_type_id: CaredFacilityType.find_by(name: 'CO2_GAS').id, activation_date: Time.now, serial_number: 'CO2-001', model: 'X100', inuse: true, enabled: true },
  { name: '緊急按鈕1', cared_user_info_id: 2, cared_facility_type_id: CaredFacilityType.find_by(name: 'EmergencyButton').id, activation_date: Time.now, serial_number: 'EMG-001', model: 'BTN-A1', inuse: true, enabled: true }
])

end
