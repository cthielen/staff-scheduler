every 1.day, :at => '6:00 am' do
  runner "Schedule.daily_scheduled_tasks"
end
