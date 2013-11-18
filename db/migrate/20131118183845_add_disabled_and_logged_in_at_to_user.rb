class AddDisabledAndLoggedInAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :disabled, :boolean, default: false
    add_column :users, :logged_in_at, :datetime
  end
end
