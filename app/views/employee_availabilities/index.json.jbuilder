json.array!(@employee_availabilities) do |employee_availability|
  json.extract! employee_availability, :start_datetime, :end_datetime, :employee_id
  json.url employee_availability_url(employee_availability, format: :json)
end
