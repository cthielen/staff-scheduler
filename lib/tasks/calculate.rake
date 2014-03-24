require 'rake'
require 'pp'
namespace :calculate do
  desc 'Outputs the ideal shift_assignments for a given schedule.'
  task :schedule => :environment do

    employees = []
    shifts = []
    schedule = Schedule.first
    # Schedule generation uses the first monday-friday block of days as its template
    # If a schedule for example starts on a thursday, calculations will be based on the monday-friday of the following week
    # Note: if the first week has holidays/irregular shifts/availability, calculations will be very off
    $first_week_start = identify_week_start(schedule)
    $first_week_end = $first_week_start + 4.days
        
    schedule.employees.each do |e|
      employees[e.id] = {id: e.id, name: e.name, max_hours: e.max_hours, skills: [], locations: []}
      e.skills.each do |s|
        employees[e.id][:skills][s.id] = {id: s.id}
      end
      e.locations.each do |l|
        employees[e.id][:locations][l.id] = {id: l.id}
      end
      e.employee_availabilities.each do |a|
        employees[e.id][:availabilities][a.id] = {id: a.id, start_datetime: a.start_datetime, end_datetime: a.end_datetime}     
      end 
    end

    schedule.shifts.each do |shift|
      shifts[shift.id] = {id: shift.id, start_datetime: shift.start_datetime, end_datetime: shift.end_datetime, skill: shift.skill_id, location: shift.location_id}    
    end
#    avail_fragments = generate_availability_fragments(employees)
    shift_fragments = generate_shift_fragments(shifts)

    # (2400 + ) represents Tuesday (24 hours after Monday)
    $availabilities = [{start: 9, end: 9.5, skill: 1}, {start: 9.5, end: 10, skill: 1}, {start: 9.5, end: 10, skill: 0}, {start: 10, end: 10.5, skill: 1}, {start: 10.5, end: 11, skill: 1}, {start: 10.5, end: 11, skill: 1}, {start: 24 + 10, end: 24 + 10.5, skill: 1}, {start: 24 + 10.5, end: 24 + 11, skill: 1}, {start: 24 + 10.5, end: 24 + 11, skill: 1}]

    $shifts = [{start: 9.5, end: 10, skill: 1}, {start: 10, end: 10.5, skill: 0}, {start: 24 + 9, end: 24 + 9.5, skill: 0}, {start: 24 + 10.5, end: 24 + 11, skill: 0}]


    solution_size = $shifts.length
    assignment_space = (0..$availabilities.length - 1).to_a

    ArrayNode.solve!(nil, Array.new(solution_size), assignment_space)
  end
end

# Returns false if any constraints are not met
def fails_constraint(datum)
  # Go through schedule (datum) assignments made (datum[i])
  datum.each_with_index do |d, i|
    # If one has been set (not nil ...)
    if d
      # Ensure timing of availability 'd' fits in the shift
      return true if $availabilities[d][:start] != $shifts[i][:start]
      return true if $availabilities[d][:skill] < $shifts[i][:skill]
    end
  end
  
  return false
end

# Returns an array of all availabilities, cut into 30 minute time blocks
def generate_availability_fragments(employees) 
  fragments = []
  employees.each do |employee|
    if employee
      employee[:availabilities].each do |availability|
        # TODO: slice up availablity into 30min blocks
      end
    end
  end
end

# Returns an array of all shifts in the schedule, cut into 30 minute time blocks
def generate_shift_fragments(shifts)
  fragments = []
  shifts.each do |shift|
    if shift    
      # Only interested in shifts from the first 5 weekdays)
      if (shift[:start_datetime] > $first_week_start) && (shift[:start_datetime] < $first_week_end)
        slice = shift[:start_datetime]
        while slice < shift[:end_datetime]
          fragments.push({id: shift[:id], start: slice, end: slice + 30.minutes})
          slice = slice + 30.minutes
        end      
      end
    end
  end
  fragments
end

def identify_week_start(schedule)
  week_start = schedule.start_date
  while week_start.wday != 1
    week_start = week_start + 1.days
  end
  week_start
end

class ArrayNode
  def ArrayNode.solve!(parent, datum, references)
    # Analyze datum for correctness
    return false if fails_constraint(datum)

    puts "Solution           : " + datum.to_s
    
    # Branch
    datum.each_with_index do |d, i|
      if d == nil
        references.each_with_index do |r, j|
          modified_datum = datum.clone
          modified_datum[i] = r
          modified_references = references.clone
          modified_references.delete_at(j)
          ArrayNode.solve!(self, modified_datum, modified_references)
        end
      end
    end
  end
end
