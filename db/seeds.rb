# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

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
