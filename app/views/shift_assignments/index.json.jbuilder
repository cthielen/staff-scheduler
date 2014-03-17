json.array!(@shift_assignments) do |shift_assignment|
  json.extract! shift_assignment, :id, :employee_id, :is_confirmed, :shift_id
  json.title shift_assignment.employee.name
  json.start shift_assignment.start_datetime
  json.end shift_assignment.end_datetime
end
