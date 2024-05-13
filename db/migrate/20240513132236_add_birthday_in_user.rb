class AddBirthdayInUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :birthday, :datetime
  end
end
