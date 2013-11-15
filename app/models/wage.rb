class Wage < ActiveRecord::Base
  belongs_to :employee, touch: true
  
  validates :amount, :employee_id, :starting_date, presence: true
end
