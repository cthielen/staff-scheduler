class LocationAssignment < ActiveRecord::Base
  belongs_to :employee
  belongs_to :location
  
  validates :location_id, :employee_id, presence: true  
end
