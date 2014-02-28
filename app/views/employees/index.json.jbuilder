json.array!(@employees) do |employee|
  json.extract! employee, :id, :max_hours, :email, :name, :is_disabled
  json.url employee_url(employee, format: :json)
  json.skills employee.skills do |skill|
    json.extract! skill, :id, :title
  end
  json.locations employee.locations do |location|
    json.extract! location, :id, :name
  end
end
