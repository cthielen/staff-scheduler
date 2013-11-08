class ApplicationController < ActionController::Base
  before_action CASClient::Frameworks::Rails::Filter
  before_action :set_current_user
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  require 'declarative_authorization/maintenance'
  include Authorization::Maintenance
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
