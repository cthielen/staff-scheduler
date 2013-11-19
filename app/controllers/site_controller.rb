class SiteController < ApplicationController
  skip_before_filter :authenticate, :only => [:status, :welcome, :access_denied]
  respond_to :html
  
  def welcome
    respond_to do |format|
      format.html { render 'welcome', layout: false }
    end
  end
  
  def access_denied
    respond_to do |format|
      format.html { render 'access_denied', layout: false }
    end
  end
  
  def signup
    SignUpMailer.signup_email(signup_params).deliver
    
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end
  
  def signup_params
    params.require(:site).permit(:name, :email, :reason)
  end
end
