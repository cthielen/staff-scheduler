class StaffMailer < ActionMailer::Base
  default from: "no-reply@dss.ucdavis.edu"
  
  def send_email(message, recipients, subject)
    @message = message
    mail(:subject => subject, :bcc => recipients)
  end
end
