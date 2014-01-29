class ShiftAssignment < ActiveRecord::Base
  using_access_control
  after_save :notify_absence
  
  belongs_to :employee
  belongs_to :shift
  belongs_to :shift_assignment_status, :foreign_key => 'status_id'
  
  validates :start_datetime, :end_datetime, :employee_id, :status_id, :shift_id, presence: true
  validates :is_confirmed, :inclusion => {:in => [true, false]}
  
  def notify_absence
    if self.shift_assignment_status.name == "absence"
      recipients = self.employee.pluck(:email)
      StaffMailer.notify_absence(recipients).deliver
    end
  end
end
