class DeleteShiftExceptionsTable < ActiveRecord::Migration
  def change
    drop_table :shift_exceptions
  end
end
