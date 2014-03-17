json.array!(@employee_schedules) do |employee_schedule|
  json.extract! employee_schedule, :id, :employee_id, :schedule_id, :availability_submitted
end
