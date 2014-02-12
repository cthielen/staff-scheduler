json.array!(@skills) do |skill|
  json.extract! skill, :id, :title, :is_disabled
  json.url skill_url(skill, format: :json)
end
