json.array!(@skill_assignments) do |skill_assignment|
  json.extract! skill_assignment, :employee_id, :skill_id
  json.url skill_assignment_url(skill_assignment, format: :json)
end
