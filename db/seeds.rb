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

  # 為社區創建相關的社區資料
  CommunityProfile.create!(
    community_id: community.id,
    line_at_url: 'https://line.me/R/ti/p/%40916lsfmg',
    line_login_channel_id: '2004751931',
    line_login_channel_secret: '5a4926d24141786c580dfce1120b5bb0',
    line_login_channel_callback_url: 'https://https://padifield.hopto.org/callback',
    line_liff_id: '2004751931-1jrD53LP',
    line_liff_url: 'https://liff.line.me/2004751931-POn4oBxp',
    line_message_api_channel_id: '2005495451',
    line_message_api_channel_secret: 'e68fa550601f58ae463e80c68fe6282f',
    line_message_api_channel_callback_url: 'https://padifield.hopto.org/callback',
    line_message_api_channel_token: 'rJt8P861M/mrTjyXvB+JJeCnFAQovEq03VXE+M2cpP+PLt857iW4Pkj0p27xF6pds4w2GHMRLCG/EFNPAqX28B1QwVJE8kAfLbklYnn/N43HsD6npAczVtfONi2BxPi21Ys7oAEoDOuxcIOnxlDWPgdB04t89/1O/w1cDnyilFU=',
    google_map_key: 'AIzaSyAIrjnyChM8LHj1xInbMWFlGye5LxFaatU',
    note: '初始設定',
    comment: '2025年設定'
  )
  puts "Created a new community profile for community '#{community.name}'"
end

# 找到 user id 是 1 的資料
user = User.find_by(id: 1)

# 宣告一個變數來存儲新建立的使用者
new_user = nil

if user
  new_user = user
else
  # 如果找不到 user id 是 1 的資料，創建一個新的 user
  new_user = User.create!(
    id: 1,
    community_id: community.id, # 將user關聯到新創建的社區
    name: '洪晨峰',
    account: 'Ua435ab1c9143f1197062ef996cda2916',
    oauth_token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVWE0MzVhYjFjOTE0M2YxMTk3MDYyZWY5OTZjZGEyOTE2IiwiYXVkIjoiMjAwNTQ5NTQ1MSIsImV4cCI6MTczOTg2NTkyNSwiaWF0IjoxNzM5ODYyMzI1LCJhbXIiOlsibGluZWF1dG9sb2dpbiJdLCJuYW1lIjoiY2hlbmZ1biIsInBpY3R1cmUiOiJodHRwczovL3Byb2ZpbGUubGluZS1zY2RuLm5ldC8waHlNV3NKdUZpSm1KcUNqZW1KUzFaTlZaUEtBOGRKQ0FxRW1WdEJCb0NmRkJCUDJneVVUZzVCMHdQS0ZSUE9HSThCRGhyQVU1ZExBVlAifQ._aE0kzk-Nd6MWpdXz3aWcMhB9D9FKb3NPbFM5XZaLG8',
    email: 'chenfun_b51@hotmai.com',
    phone: '0938692600',
    id_card: 'N125571815',
    password: '123456789',
    created_at: Time.now
  )
  puts 'Created a new user with id 1'
end

# 找到 user_profiles 表格中的相關資料
user_profile = User::Profile.find_by(user_id: new_user.id)

if user_profile
  puts "User profile already exists for user id #{new_user.id}"
else
  # 創建新的 user_profile
  User::Profile.create!(
    id: 1,
    user_id: new_user.id,
    line_uid: 'Ua435ab1c9143f1197062ef996cda2916',
    line_token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVWE0MzVhYjFjOTE0M2YxMTk3MDYyZWY5OTZjZGEyOTE2IiwiYXVkIjoiMjAwNTQ5NTQ1MSIsImV4cCI6MTczOTg2NTkyNSwiaWF0IjoxNzM5ODYyMzI1LCJhbXIiOlsibGluZWF1dG9sb2dpbiJdLCJuYW1lIjoiY2hlbmZ1biIsInBpY3R1cmUiOiJodHRwczovL3Byb2ZpbGUubGluZS1zY2RuLm5ldC8waHlNV3NKdUZpSm1KcUNqZW1KUzFaTlZaUEtBOGRKQ0FxRW1WdEJCb0NmRkJCUDJneVVUZzVCMHdQS0ZSUE9HSThCRGhyQVU1ZExBVlAifQ._aE0kzk-Nd6MWpdXz3aWcMhB9D9FKb3NPbFM5XZaLG8',
    line_name: 'chenfun',
    line_image: 'https://profile.line-scdn.net/0hyMWsJuFiJmJqCjemJS1ZNVZPKA8dJCAqEmVtBBoCfFBBP2gyUTg5B0wPKFRPOGI8BDhrAU5dLAVP'
  )
  puts "Created a new user profile for user id #{new_user.id}"
end

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
  # 為社區創建相關的社區資料
  CommunityProfile.create!(
    community_id: community2.id,
    line_at_url: 'https://line.me/R/ti/p/%40519dlpmy',
    line_login_channel_id: '2007069569',
    line_login_channel_secret: '2b1bf5bcea68cb1598a3f29ede6eb8cd',
    line_login_channel_callback_url: 'https://https://padifield.hopto.org/callback',
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
