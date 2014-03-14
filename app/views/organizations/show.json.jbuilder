json.extract! @organization, :id, :title, :created_at, :updated_at
json.employees @organization.employees do |employee|
  json.extract! employee, :id, :name
end
json.schedules @organization.schedules do |schedule|
  json.extract! schedule, :id, :name
end
