class Location < ActiveRecord::Base
  has_many :employees, through: :location_assignments
  has_many :shifts, touch: true
  
  validates :name, presence: true, uniqueness: true

end
