class Wage < ActiveRecord::Base
  belongs_to :employee
  validates :amount, :employee_id, :start_datetime, presence: true
end
