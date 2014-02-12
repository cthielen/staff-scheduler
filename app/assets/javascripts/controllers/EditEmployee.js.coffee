StaffScheduler.controller "EditEmployeeCtrl", @EditEmployeeCtrl = ($scope, $modalInstance, employee, Employees) ->
  $scope.employee = employee
  $scope.submitText = 'Update Employee'
  
  $scope.clearError = ->
    $scope.error = null

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'
    Employees.update $scope.employee,
      (data) ->
        # Success
        $modalInstance.close $scope.employee
      (data) ->
        # Failure
        $scope.error = 'Could not save employee, please try saving again'
        $scope.submitText = 'Try Again'

  $scope.close = ->
    $modalInstance.dismiss "cancel"
