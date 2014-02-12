class LocationAssignment < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee
  belongs_to :location
  
  validates :location, :employee, presence: true
  validates :location_id, :employee_id, presence: true  
  
end
