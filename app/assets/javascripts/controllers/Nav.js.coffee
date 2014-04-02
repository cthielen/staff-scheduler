StaffScheduler.controller "NavCtrl", @NavCtrl = ($scope, Schedules) ->

  $scope.schedules = Schedules.query {},
    (schedules) ->
      # Success
    (schedules) ->
      # Error
      $scope.error = "Error loading schedules!"
