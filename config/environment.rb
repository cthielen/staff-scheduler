# Load the Rails application.
require File.expand_path('../application', __FILE__)

require "casclient"
require "casclient/frameworks/rails/filter"

# Initialize the Rails application.
StaffScheduler::Application.initialize!

CASClient::Frameworks::Rails::Filter.configure(:cas_base_url => "https://cas.ucdavis.edu/cas/")
