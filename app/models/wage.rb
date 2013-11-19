class Wage < ActiveRecord::Base
  using_access_control
  
  belongs_to :employee, touch: true
  
  validates :amount, :employee_id, :starting_date, presence: true
end
