class NotifyMailer < ActionMailer::Base
  default from: "no-reply@dss.ucdavis.edu"
  
  def schedule_complete_email
    mail(to: "ltwheeler@ucdavis.edu", subject: 'emailing managers')
  end

  def absence_email
    mail(to: "ltwheeler@ucdavis.edu", subject: 'emailing managers')
  end

  def unfilled_absence_email
    mail(to: "ltwheeler@ucdavis.edu", subject: 'emailing managers')
  end
  
  def schedule_conflict_email
    mail(to: "ltwheeler@ucdavis.edu", subject: 'emailing managers')
  end  
  
  def availability_confirmations_complete_email
    mail(to: "ltwheeler@ucdavis.edu", subject: 'emailing managers')
  end
end
