class ApplicationController < ActionController::Base
  include Authentication
  before_action :authenticate
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    User.find_by_loginid(session[:cas_user])
  end
  
  def set_current_user
    if current_user
      Authorization.current_user = current_user
    else
      render :text => "You do not have permission to access this application.", :status => 403
    end
  end
end
