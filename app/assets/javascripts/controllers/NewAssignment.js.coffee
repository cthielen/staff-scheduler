StaffScheduler.controller "NewAssignmentCtrl", @NewAssignmentCtrl = ($scope, $modalInstance, newAssignment, Employees) ->
  $scope.submitText = 'Create Assignment'
  $scope.status = "loading..."

  Employees.query {
    shift: newAssignment.shift_id,
    start: new Date(newAssignment.start_datetime),
    end: new Date(newAssignment.end_datetime)
  },
    (data) ->
      # Sccuess
      $scope.eligibleEmployees = data
      $scope.status = "No eligible employees found!" unless data.length
    (data) ->
      # Failure
      $scope.error = "Error fetching eligible employees"
  
  $scope.createAssignment = (employee) ->
    employee.shift_assignments_attributes = employee.assignments.concat(newAssignment)
    Employees.update employee,
      (data) ->
        # Success
        $modalInstance.close data
      (data) ->
        # Failure
        $scope.error = 'Could not save assignment, please try saving again'
        $scope.submitText = 'Try Again'
        # Display specific errors
        _.each(data.data , (e,i) ->
            $scope.error = $scope.error + "<li>#{i}: #{e}</li>"
          )

  $scope.clearError = ->
    $scope.error = null

  $scope.close = ->
    $modalInstance.dismiss "cancel"
