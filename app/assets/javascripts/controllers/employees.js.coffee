StaffScheduler.controller "EmployeesCtrl", @EmployeesCtrl = ($scope, $http) ->
  $(".navbar-nav li").removeClass "active"
  $("li#employees").addClass "active"

  $scope.employees = []

  # Render employees table
  $http.get("/employees.json").success( (data, status, headers, config) =>
    $scope.employees = data;
    console.log data
  ).error( (data, status, headers, config) ->
    console.log 'oh noes'
  )