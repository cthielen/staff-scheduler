class EmployeeAvailability < ActiveRecord::Base
  belongs_to :employee

  validates :start_datetime, :end_datetime, presence: true

end
