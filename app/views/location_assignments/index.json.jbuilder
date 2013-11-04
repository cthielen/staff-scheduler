json.array!(@location_assignments) do |location_assignment|
  json.extract! location_assignment, :location_id, :employee_id
  json.url location_assignment_url(location_assignment, format: :json)
end
