StaffScheduler.controller "SchedulesCtrl", @SchedulesCtrl = ($scope, $routeParams, Schedules) ->
  $(".navbar-nav li").removeClass "active"
  $("li#schedules").addClass "active"
  
  $scope.schedules = Schedules.query()
