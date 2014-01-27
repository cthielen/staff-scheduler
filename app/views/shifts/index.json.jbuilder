json.array!(@shifts) do |shift|
  json.extract! shift, :id, :start_datetime, :end_datetime, :is_mandatory, :location_id, :skill_id, :schedule_id
  json.url shift_url(shift, format: :json)
  json.title shift.location_id.to_s
  json.start shift.start_datetime
  json.end shift.end_datetime
  json.allDay false
end
