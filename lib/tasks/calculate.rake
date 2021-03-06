require 'rake'
require 'pp'
namespace :calculate do
  desc 'Outputs the ideal shift_assignments for a given schedule.'
  task :schedule => :environment do

    require 'ruby-prof'

    # Profile the code
    RubyProf.start

    # For runtime estimation
    start_time = Time.now
    schedule = Schedule.first
    $node_count = 0
    # User Configurations
    $min_time_block_size = 30 # In minutes
    $min_shift_assignment_size = 120 # In minutes    
    $schedule_max_hours = schedule.max_hours # In hours 
    $coverage_importance = 70
    $fairness_importance = 30
    
    # Schedule generation uses the first monday-friday block of days as its template
    # If a schedule for example starts on a thursday, 
    # calculations will be based on the monday-friday of the following week
    # Note: if the first week has holidays/irregular shifts/availability, solutions will be poor
    $first_week_start = (identify_week_start(schedule)).to_datetime.to_i / 60
    $first_week_end = $first_week_start + (4.days.to_i / 60)
    

    # Database dump
    $employees = [] # has skills/locations/availabilities nested
    $shifts = Hash.new
    $availabilities = Hash.new # For quickly associating shift_assignments back to $employees
    
    puts "Beginning preliminary work"
    time = Time.now
    schedule.employees.each do |e|
      $employees[e.id] = {id: e.id, name: e.name, global_max_hours: e.global_max_hours, skills: [], locations: [], availabilities: []}
      e.skills.each do |s|
        $employees[e.id][:skills][s.id] = {id: s.id}
      end
      e.locations.each do |l|
        $employees[e.id][:locations][l.id] = {id: l.id}
      end
      e.employee_availabilities.each do |a|
        $availabilities[a.id] = {id: a.id, start_datetime: ((a.start_datetime.to_i) / 60), end_datetime: ((a.end_datetime.to_i) / 60), employee_id: e.id}
        $employees[e.id][:availabilities][a.id] = {id: a.id, start_datetime: ((a.start_datetime.to_i) / 60), end_datetime: ((a.end_datetime.to_i) / 60)} 
      end 
    end
    schedule.shifts.each do |shift|
      $shifts[shift.id] = {id: shift.id, start_datetime: ((shift.start_datetime.to_i) / 60), end_datetime: ((shift.end_datetime.to_i) / 60), skill: shift.skill_id, location: shift.location_id, is_mandatory: shift.is_mandatory}
    end
        
    # Prepare data for solving 
    $availability_fragments = generate_availability_fragments
    $shift_fragments = generate_shift_fragments
    puts "availability fragments count: " + $availability_fragments.count.to_s
    puts "shift fragments count: " + $shift_fragments.count.to_s
    # Generate solutions
    solution_size = $shift_fragments.length
    assignment_space = (0..$availability_fragments.length - 1).to_a
    $solutions = []
    puts "solution size: " + solution_size.to_s
    puts "assignment space: " + assignment_space.to_s
    puts "Preliminary work complete. Elapse Time " + (Time.now - time).to_s
    time = Time.now
    puts "Beginning solution generation..."
    depth = 0
    ArrayNode.solve!(nil, Array.new(solution_size), assignment_space, depth)
    puts "Solution generation complete. Elapsed Time " + (Time.now - time).to_s
    puts "Beginning solution scoring..."

    # Filter solutions for duplicates
    
    # TODO

    # Score solutions
    top_score = 0
    top_solution = []
 #  $solutions.each do |solution|
 #    puts "solution: " + solution[:solution].to_s
 #    s = solution[:score] = fitness_score(solution)
 #    puts "score: " + s.to_s
 #    if s > top_score
 #      top_score = s
 #      top_solution = solution[:solution]
 #    end
 #   end
    end_time = Time.now
#    puts "Top Solution: " + top_solution.inspect.to_s
#    puts "Top Score: " + top_score.to_s
#    puts "solution count: " + $solutions.count.to_s
    puts "Total Run Time: " + (end_time - start_time).to_s
    puts "Nodes considered Count " + $node_count.to_s
    result = RubyProf.stop

    # Print a flat profile to text
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT)
  end
end

def fitness_score(solution)
  score = 0
  coverage_score = coverage_percentage(solution) * $coverage_importance
#  puts "coverage_score: " + coverage_score.to_s
  fairness_score = fairness_percentage(solution) * $fairness_importance
#  puts "fairness_score: " + fairness_score.to_s
  
  score += coverage_score + fairness_score

  # Critical Priority (binary checks that result in a score of zero when any are failed)

  unless required_shifts_filled?(solution)
    return 0
  end
  unless under_weekly_hour_caps?(solution)
    return 0
  end

  #TODO
  # Did an employee work more than daily_hour_cap?
  # Did an employee work a shift_assignment shorter than min_shift_assignment_size?
  # Is there a shift_assignment for an employee without the necessary skill/locations?

  score
end


def under_daily_hour_cap?(solution)
end

# Considers employee's global_max_hours and schedule max_hours 
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
      employee_max = $employees[k][:global_max_hours]
      if employee_max
        if v > employee_max
          return false
        end
      end
      if $schedule_max_hours
        if v > $schedule_max_hours
          return false
        end
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
          time = a[:end_datetime] - a[:start_datetime]
          employee_availability[employee_id] += time
          total_availability_hours += time
        end
      end
    end
  end
  
  avg_availability_hours = (total_availability_hours) / $employees.count

  # Build unfair_hours count
  $employees.each do |e|
    if e
      employee_id = e[:id]
      available_hours = employee_availability[employee_id]
      assigned = assigned_hours[employee_id]   
      unless available_hours.nil? || available_hours == 0
        ideal_hours = (avg_assigned_hours) * ((avg_availability_hours.to_f / available_hours.to_f) * 100)
        # Capturing the degree of difference between fair and assigned
        unfairness = (assigned.to_i - ideal_hours.to_i).abs
        unfair_hours += unfairness
      end
    end
  end

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
          if (availability[:start_datetime] > $first_week_start) && (availability[:start_datetime] < $first_week_end)
            slice = availability[:start_datetime]
            while slice < availability[:end_datetime]
              fragments.push({availability_id: availability[:id], start: slice, end: (slice + $min_time_block_size) })
              slice = slice + $min_time_block_size.to_i
            end
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
        fragments.push({shift_id: shift[:id], start: slice, end: slice + $min_time_block_size})
        slice = slice + $min_time_block_size
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
  def ArrayNode.solve!(parent, datum, references, depth)
    $node_count+=1
    # Analyze datum for correctness
    return false if fails_constraint(datum, depth)

    unless $solutions[depth]
      $solutions[depth] = []
    end
    $solutions[depth].push({solution: datum, score: nil})

    # Branch
    datum.each_with_index do |d, i|
      if d == nil
        references.each_with_index do |r, j|
          modified_datum = datum.clone
          modified_datum[i] = r
          modified_references = references.clone
          modified_references.delete_at(j)
          ArrayNode.solve!(self, modified_datum, modified_references, (depth + 1))
        end
      end
    end
  end
end

# Returns false if any constraints are not met
def fails_constraint(datum, depth)
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
  
  # Ensuring solution is not a duplicate
  if $solutions[depth]
    $solutions[depth].each_with_index do |s, i|
      if datum == s[:solution]
        return true
      end
    end
    return false
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
