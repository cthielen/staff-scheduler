json.array!(@employees) do |employee|
  json.extract! employee, :max_hours, :email, :name, :is_disabled
  json.url employee_url(employee, format: :json)
end
