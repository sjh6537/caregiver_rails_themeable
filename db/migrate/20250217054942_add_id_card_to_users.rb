class AddIdCardToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :id_card, :string
    add_index :users, :id_card
  end
end
