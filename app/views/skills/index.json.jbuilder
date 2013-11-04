json.array!(@skills) do |skill|
  json.extract! skill, :title
  json.url skill_url(skill, format: :json)
end
