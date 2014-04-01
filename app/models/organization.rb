class Organization < ActiveRecord::Base
  using_access_control

  has_many :schedules
  has_and_belongs_to_many :users

  validates :title, presence: true

end
