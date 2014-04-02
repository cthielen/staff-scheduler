StaffScheduler.controller "NavCtrl", @NavCtrl = ($scope, Schedules) ->


  $scope.schedules = Schedules.query {},
    (schedules) ->
      # Success
      console.log schedules
    (schedules) ->
      # Error
      $scope.error = "Error loading schedules!"
