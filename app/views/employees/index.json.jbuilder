json.array!(@employees) do |employee|
  json.extract! employee, :id, :global_max_hours, :email, :name, :is_disabled
  json.url employee_url(employee, format: :json)
  json.skills employee.skills do |skill|
    json.extract! skill, :id, :title
  end
  json.locations employee.locations do |location|
    json.extract! location, :id, :name
  end
  json.assignments employee.shift_assignments do |assignment|
    json.extract! assignment, :id, :start_datetime, :end_datetime, :shift_id, :status_id
  end
  json.availabilities employee.employee_availabilities do |availability|
    json.extract! availability, :id, :start_datetime, :end_datetime, :schedule_id
  end
end
