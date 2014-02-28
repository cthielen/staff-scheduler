StaffScheduler.controller "EditEmployeeCtrl", @EditEmployeeCtrl = ($scope, $modalInstance, employee, Employees, Skills, Locations) ->
  $scope.employee = employee
  $scope.checked = true
  $scope.submitText = 'Update Employee'
  $scope.skills = Skills.query()

  Locations.query {}, (result) ->
    # Success
    $scope.locations = []
    angular.forEach result, (item) ->
      item.assigned = true if _.find($scope.employee.locations, (l) -> l.id == item.id)
      $scope.locations.push item if item.id

  Skills.query {}, (result) ->
    # Success
    $scope.skills = []
    angular.forEach result, (item) ->
      item.assigned = true if _.find($scope.employee.skills, (s) -> s.id == item.id)
      $scope.skills.push item if item.id

  $scope.clearError = ->
    $scope.error = null

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'

    $scope.employee.location_assignments_attributes = _.map(
        _.filter($scope.locations, (l) ->l.assigned), (loc) -> {location_id: loc.id}
      )
    $scope.employee.skill_assignments_attributes = _.map(
        _.filter($scope.skills, (s) -> s.assigned), (skl) -> {skill_id: skl.id}
      )

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
