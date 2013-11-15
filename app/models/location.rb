class Location < ActiveRecord::Base
  has_many :location_assignments, dependent: :destroy
  has_many :employees, through: :location_assignments
  has_many :shifts
  
  validates :name, presence: true, uniqueness: true

end
