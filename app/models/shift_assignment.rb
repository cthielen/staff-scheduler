class ShiftAssignment < ActiveRecord::Base
  using_access_control
  after_save :notify_absence
  
  belongs_to :employee
  belongs_to :shift
  belongs_to :shift_assignment_status, :foreign_key => 'status_id'

  validates :employee, :shift, :shift_assignment_status, presence: true
  validate :shift_assignment_must_fit_inside_shift, :end_date_must_be_later_than_start_date, :planned_or_completed_shift_assignments_cannot_overlap
  validates :start_datetime, :end_datetime, :employee_id, :status_id, :shift_id, presence: true
  validates :is_confirmed, :inclusion => {:in => [true, false]}
  
  def notify_absence
    if self.shift_assignment_status.present?    
      if self.shift_assignment_status.name == "absence"
        recipients = self.employee.pluck(:email)
        StaffMailer.notify_absence(recipients).deliver
      end
    end
  end
  
  def end_date_must_be_later_than_start_date
    if self.end_datetime.present?
      if self.end_datetime < self.start_datetime
        errors.add(:end_date, "End date must come after start date")
      end
    end
  end
  
  def shift_assignment_must_fit_inside_shift
    if self.shift.present?
      if self.start_datetime < self.shift.start_datetime
        errors.add(:start_datetime, "shift_assignment start_datetime must fall wtihin its shift")
      elsif self.end_datetime > self.shift.end_datetime
        errors.add(:end_datetime, "shift_assignment end_datetime must fall wtihin its shift")    
      end
    end
  end
  
  # ensure that an assignment cannot be made if it overlaps with an existing shift_assignment of status 'planned' or 'completed'
  def planned_or_completed_shift_assignments_cannot_overlap
    if self.shift.present? && self.shift.shift_assignments.present?
      self.shift.shift_assignments.each do |assignment|
        if scheduled?
          unless (self.start_datetime < assignment.start_datetime) && (self.end_datetime <= assignment.end_datetime)
            errors.add(:start_datetime, "shift_assignment cannot overlap an existing planned shift_assignment on the same shift")       
          end
          unless (self.start_datetime >= assignment.end_datetime) && (self.end_datetime > assignment.end_datetime)
            errors.add(:end_datetime, "shift_assignment cannot overlap an existing planned shift_assignment on the same shift")               
          end        
        end
      end
    end
  end
  
  # Combines commonly paired checks for 'planned' and 'completed'
  def scheduled?
    if completed? || planned?
      true
    else
      false
    end
  end
  def completed?
    if shift_assignment_status.name == "completed"
      true
    else
      false
    end
  end
  def planned?
    if shift_assignment_status.name == "planned"
      true
    else
      false
    end
  end
end
