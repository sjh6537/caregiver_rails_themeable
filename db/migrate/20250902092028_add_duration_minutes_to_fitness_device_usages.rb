class AddDurationMinutesToFitnessDeviceUsages < ActiveRecord::Migration[7.1]
  def change
    add_column :fitness_device_usages, :duration_minutes, :integer
  end
end
