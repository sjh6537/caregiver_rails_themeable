class AddUserIdToFitnessDevices < ActiveRecord::Migration[7.1]
  def change
    add_column :fitness_devices, :user_id, :integer
  end
end
