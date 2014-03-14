json.extract! @schedule, :id, :name, :start_date, :end_date, :created_at, :updated_at
json.shifts @schedule.shifts do |shift|
  json.extract! shift, :id, :start_datetime, :end_datetime, :location_id, :skill_id
end
json.employee_schedules @schedule.employee_schedules do |employee_schedule|
  json.extract! employee_schedule, :id, :employee_id, :availability_submitted
end
