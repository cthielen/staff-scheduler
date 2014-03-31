class Organization < ActiveRecord::Base
  using_access_control

  has_and_belongs_to_many :employees
  has_many :schedules
  has_and_belongs_to_many :users

  validates :title, presence: true

end
