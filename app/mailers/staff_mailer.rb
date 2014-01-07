class StaffMailer < ActionMailer::Base
  default from: "no-reply@dss.ucdavis.edu"
  
  def send_email(message, recipient, subject)
    @message = message
    mail(:to => "#{recipient.name} <#{recipient.email}>", :subject => subject)
  end
end
