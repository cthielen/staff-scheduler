json.array!(@shift_assignment_statuses) do |shift_assignment_status|
  json.extract! shift_assignment_status, :id, :name
  json.url shift_assignment_status_url(shift_assignment_status, format: :json)
end
