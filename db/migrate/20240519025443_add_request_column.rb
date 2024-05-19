class AddRequestColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :user_requests, :location_city, :integer, default: 0
    add_column :user_requests, :location_postal, :integer, default: 0

    add_column :user_request_receivers, :consider, :integer, default: 0
  end
end
