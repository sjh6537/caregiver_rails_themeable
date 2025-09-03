class CreateFitnessDeviceUsages < ActiveRecord::Migration[7.1]
  def change
    create_table :fitness_device_usages do |t|
      t.references :fitness_device, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
