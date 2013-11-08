class User < ActiveRecord::Base  
  validates :loginid, :is_manager, presence: true
end
