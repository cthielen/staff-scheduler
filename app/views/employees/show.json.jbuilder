json.extract! @employee, :id, :max_hours, :email, :name, :is_disabled, :created_at, :updated_at
json.availabilities @employee.employee_availabilities do |availability|
  json.extract! availability, :id, :start_datetime, :end_datetime, :schedule_id
end
json.assignments @employee.shift_assignments do |assignment|
  json.extract! assignment, :id, :start_datetime, :end_datetime, :shift_id, :status_id
end
