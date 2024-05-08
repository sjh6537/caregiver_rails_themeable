class AddProfileColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :phone, :string,                 default: ""
    add_column :users, :sex, :boolean,                  default: true
    add_column :users, :address, :string,               default: ""
    add_column :users, :addr_city, :integer,            default: 0
    add_column :users, :addr_postal, :integer,          default: 0
  end
end
