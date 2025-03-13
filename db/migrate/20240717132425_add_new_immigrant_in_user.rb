class AddNewImmigrantInUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :new_immigrant, :boolean, default: false
  end
end
