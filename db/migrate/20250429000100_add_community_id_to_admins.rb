class AddCommunityIdToAdmins < ActiveRecord::Migration[7.1]
  def change
    add_column :admins, :community_id, :integer, comment: '社區ID'
    add_index :admins, :community_id
  end
end
