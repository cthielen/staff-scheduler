StaffScheduler::Application.routes.draw do
  resources :schedules

  # resources :skill_assignments
  # resources :location_assignments
  # resources :shift_exceptions
  # resources :employee_availabilities
  # resources :locations
  # resources :skills
  # resources :shift_assignments
  # resources :shifts
  # resources :employees
  # resources :wages
  # resources :users

  root :to => 'site#welcome'
  
  post '/signup', to: 'site#signup'
  get '/access_denied', to: 'site#access_denied'
end
