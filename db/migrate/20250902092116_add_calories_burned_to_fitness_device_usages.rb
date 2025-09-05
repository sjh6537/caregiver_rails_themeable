class AddCaloriesBurnedToFitnessDeviceUsages < ActiveRecord::Migration[7.1]
  def change
    add_column :fitness_device_usages, :calories_burned, :integer
  end
end
