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
    $important_weight

    
    # Schedule generation uses the first monday-friday block of days as its template
    # If a schedule for example starts on a thursday, 
    # calculations will be based on the monday-friday of the following week
    # Note: if the first week has holidays/irregular shifts/availability, solutions will be poor
    $first_week_start = identify_week_start(schedule)
    $first_week_end = $first_week_start + 4.days
    

    # Database dump
    $employees = [] # has skills/locations/availabilities nested
    $shifts = Hash.new
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
      $shifts[shift.id] = {id: shift.id, start_datetime: shift.start_datetime, end_datetime: shift.end_datetime, skill: shift.skill_id, location: shift.location_id, is_mandatory: shift.is_mandatory}
    end
    
    # Prepare data for solving 
    $availability_fragments = generate_availability_fragments
    $shift_fragments = generate_shift_fragments

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
  score = 0
  coverage_percentage(solution)
  fairness_percentage(solution)
  # Critical Priority (binary checks that result in a score of zero when any are failed)
  # Did an employee work more than weekly_hour_cap
  # Did an employee work more than their max_hours
  # Did an employee work more than daily_hour_cap
  # Did an employee work a shift_assignment shorter than min_shift_assignment_size?
  # Is there a shift_assignment for an employee without the necessary skill/locations?
  unless required_shifts_filled?(solution)
    return 0
  end
  unless under_weekly_hour_caps?(solution)
    return 0
  end
  # What percentage of total shift time was covered?
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
    employee_id = nil
    if s
      id = $availability_fragments[s][:availability_id]  
      time = ($availability_fragments[s][:end] - $availability_fragments[s][:start]).to_i / 60    
      employee_id = $availabilities[id][:employee_id]

      unless employee_totals[employee_id].present?
        employee_totals[employee_id] = 0
      end
      
      employee_totals[employee_id] = employee_totals[employee_id] + time 
    end
    # Check total against caps
    employee_totals.each do |k, v|

      $employees[employee_id][:max_hours]
      employee_max = ($employees[employee_id][:max_hours]) 
      if v > employee_max || v > $global_max_hours
        return false
      end
    end    
  end
  return true
end

# Returns the percentage of coverage, 100 is best possible, 0 is worst possible
def coverage_percentage(solution)
  total_time = $shift_fragments.length * $min_time_block_size # In minutes
  covered_time = 0
  solution[:solution].each do |s|
    if s
      covered_time = covered_time + $min_time_block_size
    end
  end
  percentage = covered_time.to_f / total_time.to_f
  percentage = (percentage* 100).to_i # conversion to percentage without decimal
end

# Fairness is defined as the degree to which employee assigned hours match the avg assigned hours of all employees, tempered by their availability hours vs avg availability hours of all employees
# Returns the percentage of fairness, 100 is best possible, 0 is worst possible
def fairness_percentage(solution)
  total_assigned_time = 0
  total_availability_hours = 0
  avg_availability_hours = 0
  avg_assigned_hours = 0
  employee_availability = Hash.new
  assigned_hours = Hash.new
  unfair_hours = 0
  
  # Collect assigned time
  solution[:solution].each do |s|
    unless s == nil
      total_assigned_time += $min_time_block_size
      time = ($availability_fragments[s][:end] - $availability_fragments[s][:start]).to_i / 60    
      id = $availability_fragments[s][:availability_id]  
      employee_id = $availabilities[id][:employee_id]

      unless assigned_hours[employee_id].present?
        assigned_hours[employee_id] = 0
      end
      assigned_hours[employee_id] = assigned_hours[employee_id] + time 
    end
  end
  
  avg_assigned_hours = (total_assigned_time) / $employees.count
  
  # Collect availability time
  $employees.each do |e|
    if e
      employee_id = e[:id]
      employee_availability[employee_id] = 0
      e[:availabilities].each do |a|
        if a
          time = (a[:end_datetime] - a[:start_datetime]).to_i / 60 # Convert to minutes
          employee_availability[employee_id] += time
          total_availability_hours += time
        end
      end
    end
  end
  
  avg_availability_hours = (total_availability_hours) / $employees.count

  # Score each employee

  $employees.each do |e|
    if e
      employee_id = e[:id]
      available_hours = employee_availability[employee_id]
      assigned_hours = assigned_hours[employee_id]   
      unless available_hours.nil? || available_hours == 0
        ideal_hours = (avg_assigned_hours) * ((avg_availability_hours.to_f / available_hours.to_f).abs * 100)
        puts "----"
        puts available_hours
        puts "---"
        unfairness = assigned_hours.to_i - ideal_hours.to_i
        unfair_hours += unfairness
      end
    end
  end
  
  puts "total_assigned_time: " + total_assigned_time.to_s
  puts "employee count: " + $employees.count.to_s
  puts "avg_assigned_hours" + avg_assigned_hours.to_s
  puts "unfair_hours:" + unfair_hours

  if unfair_hours != 0
    ret = ((total_assigned_time.to_f / unfair_hours.to_f) * 100).to_i
    return ret
  end
  return 100
end

def required_shifts_filled?(solution)
  # loop through shifts, is it mandatory?
  $shifts.each do |skey, shift|
    if shift[:is_mandatory]
      # Loop through shift_fragments, is it tied to above shift?
      $shift_fragments.each_with_index do |fragment, fkey|
        # Is that shift_fragment covered?
        if fragment[:shift_id] == shift[:id]
          unless solution[fkey]
            return false
          end
        end        
      end
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
def generate_shift_fragments
  fragments = []
  $shifts.each do |k, shift|
    # Only interested in shifts from the first 5 weekdays)
    if (shift[:start_datetime] > $first_week_start) && (shift[:start_datetime] < $first_week_end)
      slice = shift[:start_datetime]
      while slice < shift[:end_datetime]
        fragments.push({shift_id: shift[:id], start: slice, end: slice + $min_time_block_size.minutes})
        slice = slice + $min_time_block_size.minutes
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
