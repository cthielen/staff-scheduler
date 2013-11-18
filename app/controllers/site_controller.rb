class SiteController < ApplicationController
  skip_before_filter :authenticate, :only => [:status, :welcome, :access_denied]
  
  def welcome
    respond_to do |format|
      format.html { render 'welcome', layout: false }
    end
  end
end
