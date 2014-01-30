class ShiftAssignment < ActiveRecord::Base
  using_access_control
  after_save :notify_absence
  
  belongs_to :employee
  belongs_to :shift
  belongs_to :shift_assignment_status, :foreign_key => 'status_id'

  validate :shift_assignment_must_fit_inside_shift, :end_date_must_be_later_than_start_date
  validates :start_datetime, :end_datetime, :employee_id, :status_id, :shift_id, presence: true
  validates :is_confirmed, :inclusion => {:in => [true, false]}
  
  def notify_absence
    if self.shift_assignment_status.name == "absence"
      recipients = self.employee.pluck(:email)
      StaffMailer.notify_absence(recipients).deliver
    end
  end
  
  def end_date_must_be_later_than_start_date
    if self.end_datetime < self.start_datetime
      errors.add(:end_date, "End date must come after start date")
    end
  end
  
  def shift_assignment_must_fit_inside_shift
    if self.start_datetime < self.shift.start_datetime
      errors.add(:start_datetime, "shift_assignment start_datetime must fall wtihin its shift")
    elsif self.end_datetime > self.shift.end_dateime
      errors.add(:end_datetime, "shift_assignment end_datetime must fall wtihin its shift")    
    end
  end
end
