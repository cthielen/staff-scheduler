class CreateWages < ActiveRecord::Migration
  def change
    create_table :wages do |t|
      t.integer :amount
      t.integer :employee_id
      t.date :starting_date

      t.timestamps
    end
  end
end
