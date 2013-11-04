json.array!(@shift_assignments) do |shift_assignment|
  json.extract! shift_assignment, :start_datetime, :end_datetime, :employee_id, :is_absence, :is_confirmed, :shift_id
  json.url shift_assignment_url(shift_assignment, format: :json)
end
