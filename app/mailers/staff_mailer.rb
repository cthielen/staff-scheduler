class StaffMailer < ActionMailer::Base
  default from: "no-reply@dss.ucdavis.edu"
  
  def send_email(message, recipients, subject)
    @message = message
    mail(:subject => subject, :bcc => recipients)
  end
  
  def request_availability_form
    message = "Your hours of availability are needed to begin planning the next schedule. You can submit this information on Staff-Scheduler " + root_url
    subject = "Request for availability"   
    recipients = Employee.active_employees.pluck(:email)  
    mail(:subject => subject, :bcc => recipients) do |format|
      format.text do
        render :text => message
      end
    end
  end  

  def request_assignment_confirmation_form
    subject = "Shifts assigned to you are awaiting confirmation"
    message = "Shifts have been assigned to you and are awaiting your confirmation. You can confirm your shifts on Staff-scheduler " + root_url
    recipients = Employee.active_employees.pluck(:email)
    mail(:subject => subject, :bcc => recipients) do |format|
      format.text do
        render :text => message
      end
    end
  end
  
  def request_shift_exception_fill
    subject = "A shift has become available"
    message = "A shift assignment has been dropped and is available to be claimed. Location: <location>, Skill: <skill>, start time: <start_time>, duration: <duration>. " 
    recipients = Employee.active_employees.pluck(:email)
    mail(:subject => subject, :bcc => recipients)      
  end
  
  def notify_unfilled_absence
    subject = "Unfilled shift tomorrow"
    message = "There is an unfilled absence on tomorrows schedule. You can find more information on Staff-Scheduler <link>" 
    recipients = Employee.active_managers.pluck(:email)
    mail(:subject => subject, :bcc => recipients)      
  end  
  
  def notify_unconfirmed_assignment
    subject = "Unconfirmed assignment tomorrow"
    message = "There is an unconfirmed shift assignment on tomorrows schedule. You can find more information on Staff-Scheduler <link>" 
    recipients = Employee.active_managers.pluck(:email)
    mail(:subject => subject, :bcc => recipients)        
  end
  
  def notify_availability_confirmations_complete
    subject = "Schedule is awaiting shift assignments"
    message = "All employee availabilities have been completed. The Schedule is now ready to have shift assignments filled. <link to schedule>"
    recipients = Employee.active_managers.pluck(:email)
    mail(:subject => subject, :bcc => recipients)        
  end  

  def notify_schedule_ready
    subject = "Schedule planning is complete"
    message = "All shift assignments have been confirmed by employees. The schedule is ready and will begin on <startdate>"
    recipients = Employee.active_managers.pluck(:email)
    mail(:subject => subject, :bcc => recipients)        
  end 
  
  def notify_absence(recipients)
    message = "You have been recorded as absent from your shift assignment at Location: <location>, Skill: <skill>, start time: <start_time>, duration: <duration>. " 
    subject = "Shift Absence Notification"
    mail(:subject => subject, :bcc => recipients)        
  end
end
