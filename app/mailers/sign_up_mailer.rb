class SignUpMailer < ActionMailer::Base
  default from: "no-reply@dss.ucdavis.edu"
  def signup_email(signup_params)
    @name = signup_params['name']
    @email = signup_params['email']
    @reason = signup_params['reason']
    mail(to: "ltwheeler@ucdavis.edu", subject: 'Request access for Staff Scheduler')
  end
end
