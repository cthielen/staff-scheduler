json.array!(@users) do |user|
  json.extract! user, :loginid, :employee_id, :is_manager
  json.url user_url(user, format: :json)
end
