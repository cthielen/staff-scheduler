json.array!(@shift_exceptions) do |shift_exception|
  json.extract! shift_exception, :start_datetime, :end_datetime, :employee_id, :is_absence, :shift_id
  json.url shift_exception_url(shift_exception, format: :json)
end
