require 'rake'

namespace :calculate do
  desc 'Outputs the ideal shift_assignments for a given schedule.'
  task :schedule => :environment do
  
    # Initial configuration variables
    max_hours_per_day = 8
    travel_time_buffer = 1
    schedule = Schedule.all.first
    employees = schedule.employees.all
    min_time_unit = 30.minutes # the size of the smallest time block in minutes 
     = Hash.new

    # Hard constraints
    max_num_shift_assigns_per_day = 100
    minimum_percentage_of_hours_per_week = 0
    minimum_percentage_of_schedule_covered = 0
    work_on_weekend = false

    # Soft constraints
    coverage_completeness_weighting = 5
    fairness_weighting = 5
    contiguous_assignment_weighting = 5

    #------------------
    # Tree search data structure
    #-------------------
    # Node
    # -parent node
    # -chosen assignment
    # -possible_assignments (many)
    
    # PossibleAssignemnt
    # -start_datetime
    # -end_datetime
    # -shift
    # -employee
    
    # -----------------
    # Application Process
    # ------------------
    # 1) Generate all possible_assignments
    # 2) Pick a possible_assignment, and generate a node based on that selection, recalculating possible_assignments
    # recalculate assignments from selected employee based on:
    # - new daily_max_hours total
    # - new weekly_max_hours total
    # - travel_time conflicts
    # - check assignment overlap
    # recalculate assignments from other employees based on:
    # - check assignment overlap


    # 3) If a node has no children and no possible_assignments remaining, it is a solution and needs to be scored/recorded
    # 4) If a node has no possible_assignments remaining, go to parent node to look for possible_assignments

    schedule.shifts.each do |shift|
      employees.each do |employee|
        possible_assignments(employee, shift)    
      end    
    end


  end

  # -----------
  # methods
  # ------------
  # do these 2 assignments overlap?
  def overlap?(assignment_a, assignment_b)
    ret = (assignment_a.end_datetime <= assignment_b.start_datetime) || (assignment_a.start_datetime >= assignment_b.end_datetime)  
  end
  
  # returns the block of time where two blocks of time overlap, as a single dimensional array
  def overlap(start_a, end_a, start_b, end_b)
    ret = []
    if (end_a < end_b) && (end_a > start_b)  
      ret = [start_b, end_a]
    elsif (end_a < end_b) && (end_a > start_b)  
      ret = [start_a, end_b]
    else
    ret
  end

  # does this assignment conflict with this employee's total daily_max_hours?
  def exceed_daily_max_hours?(employee, assignment)
  end

  # does this assignment conflict with this employee's total weekly_max_hours?
  def exceed_weekly_max_hours?(employee, assignment)
  end

  # does this assignment conflict with a travel_time buffer?
  def overlap_travel_buffer?(employee, assignment)
  end

  # Calculates if employee has the skills and locations necessary to work shift
  def qualified_for_shift?(employee, shift)
    if employee.skills.include? shift.skill
      if employee.locations.include? shift.location
        return true
      end
    end
    return false
  end
  
  # calculate all possible shift_assignments for the specified shift and employee - taking skills/locations/availabilities into consideration, returns a 2 dimensional array [slice_index][slice_start, slice_end]
  def possible_assignments(employee, shift)
    ret = []
    if qualified_for_shift?(employee, shift)
      employee.employee_availabilities.where(schedule_id: schedule.id).each do |avail|
        # for each availability, calculate the overlapping area, then iterate through it
        overlap = overlap(avail.start_datetime, avail.end_datetime, shift.start_datetime, shift.end_datetime)
        unless overlap.empty?
          ret.push(calculate_all_slices(overlap[0], overlap[1]) )
        end
      end
    end
  end
  
  # returns an array of all possible ways a block of time can be sliced, based on min_time_unit
  # returned as 2 dimensional array [slice_index][slice_start, slice_end]
  def calculate_all_slices(start_datetime, end_datetime)
    i = start_datetime
    slices = Array.new
    while start < end_datetime
      j = start_datetime + min_time_unit
      while j < end_datetime
        slice = [i, j]
        j = j + min_time_unit
        slices.push(slice)
      end
      start = start + min_time_unit
    end
    slices
  end

  # score a completed schedule
  def fitness_score(assignments)
  end

  # possible additions
  # incorporate backtracking
  # recognize if all weeks in the schedule have identical shift arrangements, if so it can limit calculating to a single week 
  end
end

# areas for investigation:
# - implement backtracking
# - implement logic for preferring schedules that are consistent from week to week.
