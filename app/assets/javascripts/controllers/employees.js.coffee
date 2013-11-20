StaffScheduler.controller "EmployeesCtrl", @EmployeesCtrl = ($scope, $routeParams, Employees) ->
  $(".navbar-nav li").removeClass "active"
  $("li#employees").addClass "active"

  $scope.employees = Employees.query()
  