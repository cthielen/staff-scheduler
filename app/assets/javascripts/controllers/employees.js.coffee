StaffScheduler.controller "EmployeesCtrl", @EmployeesCtrl = ($scope, $routeParams, Employees) ->
  $(".navbar-nav li").removeClass "active"
  $("li#employees").addClass "active"

  $scope.showDelete = null
  $scope.editing = null

  $scope.employees = Employees.query()
  
  $scope.showOptions = (employee) ->
    $scope.showDelete = employee.id

  $scope.hideOptions = (employee) ->
    $scope.showDelete = null

  $scope.editEmployee = (employee) ->
    $scope.editing = employee.id

  $scope.applyChanges = (employee) ->
    $scope.editing = null
    Employees.update employee

  $scope.deleteEmployee = (employee) ->
    index = $scope.employees.indexOf(employee)
    employee.is_disabled = true
    Employees.update employee, (data) ->
      $scope.employees.splice(index,1)
