class User < ActiveRecord::Base  
  belongs_to :employee
  
  validates :loginid, :is_manager, presence: true 
end
