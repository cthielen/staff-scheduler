class Location < ActiveRecord::Base
  has_many :employees, through: :location_assignments
  has_many :shifts
end
