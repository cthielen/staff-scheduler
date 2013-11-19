class SignUpMailer < ActionMailer::Base
  default from: "from@example.com"
  def signup_email
    mail(to: "ltwheeler@ucdavis.edu", subject: 'testing send on staff scheduler')
  end





end
