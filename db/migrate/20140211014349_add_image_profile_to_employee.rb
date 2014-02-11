class AddImageProfileToEmployee < ActiveRecord::Migration
  def self.up
    add_attachment :employees, :profile
  end
  
  def self.down
    remove_attachment :employees, :profile
  end
end
