json.extract! @employee, :id, :max_hours, :email, :name, :is_disabled, :created_at, :updated_at
json.shifts @employee.employee_availabilities do |availability|
  json.extract! availability, :id, :start_datetime, :end_datetime, :schedule_id
end
