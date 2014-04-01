json.extract! @employee, :id, :global_max_hours, :email, :name, :is_disabled
json.skills @employee.skills do |skill|
  json.extract! skill, :id, :title
end
json.locations @employee.locations do |location|
  json.extract! location, :id, :name
end
json.availabilities @employee.employee_availabilities do |availability|
  json.extract! availability, :id, :schedule_id
end
json.assignments @employee.shift_assignments do |assignment|
  json.extract! assignment, :id, :shift_id, :status_id
end
