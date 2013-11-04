class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :loginid
      t.integer :employee_id
      t.boolean :is_manager

      t.timestamps
    end
  end
end
