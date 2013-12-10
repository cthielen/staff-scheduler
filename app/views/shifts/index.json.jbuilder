json.array!(@shifts) do |shift|
  json.extract! shift, :start_datetime, :end_datetime, :is_mandatory, :location_id, :skill_id, :schedule_id
  json.url shift_url(shift, format: :json)
  json.name shift.location_id
  json.start shift.start_datetime
  json.end shift.end_datetime
  json.allDay false
end
