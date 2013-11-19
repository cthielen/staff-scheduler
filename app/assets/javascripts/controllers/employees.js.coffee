StaffScheduler.controller "EmployeesCtrl", @EmployeesCtrl = ($scope) ->
  $(".navbar-nav li").removeClass "active"
  $("li#employees").addClass "active"