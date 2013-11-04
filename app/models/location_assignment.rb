class LocationAssignment < ActiveRecord::Base
  belongs_to :employee
  belongs_to :location
end
