json.array!(@schedules) do |schedule|
  json.extract! schedule, :start_date, :end_date
  json.url schedule_url(schedule, format: :json)
end
