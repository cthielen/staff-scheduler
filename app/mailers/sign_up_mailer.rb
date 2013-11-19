class SignUpMailer < ActionMailer::Base
  default from: "noreply@dss.ucdavis.edu"
  def signup_email
    mail(to: "ltwheeler@ucdavis.edu", subject: 'testing send on staff scheduler')
  end





end
