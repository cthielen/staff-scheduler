every 1.day, :at => '6:00 am' do
  runner "Schedule.check_upcoming_shortages"
end
