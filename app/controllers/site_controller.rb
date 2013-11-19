class SiteController < ApplicationController
  skip_before_filter :authenticate, :only => [:status, :welcome, :access_denied]
  
  def welcome
    respond_to do |format|
      format.html { render 'welcome', layout: false }
    end
  end
  
  def signup
    @name = params[:name]
    @email = params[:email]
    @reason = params[:reason]
    SignUpMailer.signup_email().deliver
  end
  
  def signup_params
    params.require(:signup).permit(:name, :email, :reason)
  end
end
