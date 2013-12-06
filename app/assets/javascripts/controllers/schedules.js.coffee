StaffScheduler.controller "SchedulesCtrl", @SchedulesCtrl = ($scope, $routeParams, Schedules) ->
  $(".navbar-nav li").removeClass "active"
  $("li#schedules").addClass "active"
  
  $scope.schedules = Schedules.query()

  $scope.newSchedule = ->
    $scope.addNew = true

  $scope.createSchedule = ->
    # Submit only if all fields are filled
    unless ($scope.newSched['start_date'] is '' or $scope.newSched['end_date'] is '')
      Schedules.save $scope.newSched, (data) ->
        $scope.schedules.splice(0, 0, data) # Adds the item on the top of the array
        $scope.addNew = false
