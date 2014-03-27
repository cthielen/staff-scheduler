require 'rake'
require 'pp'
namespace :calculate do
  desc 'Outputs the ideal shift_assignments for a given schedule.'
  task :schedule => :environment do

    # For runtime estimation
    start_time = Time.now
    schedule = Schedule.first
        
    # User Configurations
    $min_time_block_size = 30 # In minutes
    $min_shift_assignment_size = 120 # In minutes
    # If employee max_hours is already constrained by this cap, 
    # then this constraint is implicit and can be ignored
    $global_max_hours = 20 # In hours 
    
    # Schedule generation uses the first monday-friday block of days as its template
    # If a schedule for example starts on a thursday, 
    # calculations will be based on the monday-friday of the following week
    # Note: if the first week has holidays/irregular shifts/availability, solutions will be poor
    $first_week_start = identify_week_start(schedule)
    $first_week_end = $first_week_start + 4.days
    

    # Database dump
    $employees = [] # has skills/locations/availabilities nested
    shifts = []
    $availabilities = Hash.new # For quickly associating shift_assignments back to $employees
    
    schedule.employees.each do |e|
      $employees[e.id] = {id: e.id, name: e.name, max_hours: e.max_hours, skills: [], locations: [], availabilities: []}
      e.skills.each do |s|
        $employees[e.id][:skills][s.id] = {id: s.id}
      end
      e.locations.each do |l|
        $employees[e.id][:locations][l.id] = {id: l.id}
      end
      e.employee_availabilities.each do |a|
        $availabilities[a.id] = {id: a.id, start_datetime: a.start_datetime, end_datetime: a.end_datetime, employee_id: e.id}
        $employees[e.id][:availabilities][a.id] = {id: a.id, start_datetime: a.start_datetime, end_datetime: a.end_datetime} 
      end 
    end
    schedule.shifts.each do |shift|
      shifts[shift.id] = {id: shift.id, start_datetime: shift.start_datetime, end_datetime: shift.end_datetime, skill: shift.skill_id, location: shift.location_id}
    end
    
    # Prepare data for solving 
    $availability_fragments = generate_availability_fragments
    $shift_fragments = generate_shift_fragments(shifts)

    # Generate solutions
    solution_size = $shift_fragments.length
    assignment_space = (0..$availability_fragments.length - 1).to_a
    $solutions = []

    ArrayNode.solve!(nil, Array.new(solution_size), assignment_space)

    # Score solutions
    $solutions.each do |solution|
      solution[:score] = fitness_score(solution)
    end

  #  puts $solutions
    end_time = Time.now
    puts "Total Run Time: " + (end_time - start_time).to_s
  end
end

# Returns false if any constraints are not met
def fails_constraint(datum)
  # Go through schedule (datum) assignments made (datum[i])
  datum.each_with_index do |d, i|
    # If one has been set (not nil ...)
    if d
      # Ensure timing of availability 'd' fits in the shift
      return true if $availability_fragments[d][:start] != $shift_fragments[i][:start]
      # availabilities don't have skills, seems costly to calculate
      # return true if $availability_fragments[d][:skill] < $shift_fragments[i][:skill] 
    end
  end
  
  return false
end

def fitness_score(solution)
  under_weekly_hour_caps?(solution)
  # CRITICAL weights: (binary checks that result in extremely low scores when failed)
  # Did an employee work more than weekly_hour_cap
  # Did an employee work more than their max_hours
  # Did an employee work more than daily_hour_cap
  # Did an employee work a shift_assignment shorter than min_shift_assignment_size?
  # Was a required shift not filled completely
  # Is there a shift_assignment for an employee without the necessary skill/locations?
  
  # weights:
  # What percentage of total shift time was covered?
  # What percentage of required shift time was covered?
  # How fair is the hour distribution amongst employees?
#  score
end


def under_daily_hour_cap?(solution)
end

# Considers employee's individual max_hours cap and globally set 
def under_weekly_hour_caps?(solution)
  employee_totals = Hash.new
  time_total = 0
  # Generate totals
  solution[:solution].each do |s|      
    if s
      id = $availability_fragments[s][:availability_id]  
      time = ($availability_fragments[s][:end] - $availability_fragments[s][:start]).to_i / 60    
      employee_id = $availabilities[id][:employee_id]

      unless employee_totals[employee_id].present?
        employee_totals[employee_id] = 0
      end
      
      employee_totals[employee_id] = employee_totals[employee_id] + time 
    end
  end
  
  # Check totals
  employee_totals.each do |e|
    if e > $employees[e[0]][:max_hours] || e > $global_max_hours
      return false
    end
  end
  
  return true
end

# Returns an array of all availabilities, cut into 'min_time_block_size' minute time blocks
def generate_availability_fragments 
  fragments = []
  $employees.each do |employee|
    if employee
      employee[:availabilities].each do |availability|
        if availability
          slice = availability[:start_datetime]
          while slice < availability[:end_datetime]
            fragments.push({availability_id: availability[:id], start: slice, end: slice + $min_time_block_size.minutes})
            slice = slice + $min_time_block_size.minutes
          end
        end
      end
    end
  end
  fragments
end

# Returns an array of all shifts in the schedule, cut into time blocks
def generate_shift_fragments(shifts)
  fragments = []
  shifts.each do |shift|
    if shift    
      # Only interested in shifts from the first 5 weekdays)
      if (shift[:start_datetime] > $first_week_start) && (shift[:start_datetime] < $first_week_end)
        slice = shift[:start_datetime]
        while slice < shift[:end_datetime]
          fragments.push({shift_id: shift[:id], start: slice, end: slice + $min_time_block_size.minutes})
          slice = slice + $min_time_block_size.minutes
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

    $solutions.push({solution: datum, score: nil})
    
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


# lexicon
# -------------
# availabilities: availabilities from employees associated to schedule
# availability_fragments: derived from availabilities for use in solution generation
# shifts: shifts associated to schedule from database
# shift_fragments: derived from shifts for use in solution generation
# employees: employees associated to schedule from database
# solution: a possible schedule arrangement - an array of availability_fragments and a score 
