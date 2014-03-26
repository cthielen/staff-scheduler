json.array!(@employee_availabilities) do |employee_availability|
  json.extract! employee_availability, :id, :start_datetime, :end_datetime, :employee_id
  json.title employee_availability.employee.name
  json.start employee_availability.start_datetime
  json.end employee_availability.end_datetime
  json.allDay false
end
