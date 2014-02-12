json.array!(@locations) do |location|
  json.extract! location, :id, :name, :is_disabled
  json.url location_url(location, format: :json)
end
