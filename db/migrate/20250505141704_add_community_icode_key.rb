class AddCommunityIcodeKey < ActiveRecord::Migration[7.1]
  def change
    add_column :community_profiles, :asus_icode, :string, limit: 20, comment: 'Asus 量測資料的身份證'
    add_column :community_profiles, :asus_key, :string, limit: 50, comment: 'Asus 量測資料的金鑰'
  end
end
