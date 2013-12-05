StaffScheduler.controller "SchedulesCtrl", @SchedulesCtrl = ($scope, $routeParams, Employees) ->
  $(".navbar-nav li").removeClass "active"
  $("li#schedules").addClass "active"
  