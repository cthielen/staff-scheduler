require 'rake'

namespace :calculate do
  desc 'Outputs the ideal shift_assignments for a given schedule.'
  task :schedule => :environment do
    
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
