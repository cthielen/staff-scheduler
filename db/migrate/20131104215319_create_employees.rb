class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.integer :max_hours
      t.string :email
      t.string :name
      t.boolean :disabled

      t.timestamps
    end
  end
end
