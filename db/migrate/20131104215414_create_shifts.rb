class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.boolean :is_mandatory
      t.integer :location_id
      t.integer :skill_id

      t.timestamps
    end
  end
end
