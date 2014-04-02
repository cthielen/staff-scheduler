StaffScheduler.controller "ScheduleRedirectCtrl", @ScheduleRedirectCtrl = ($scope, $location, Schedules) ->

  Schedules.query { active: true },
    (schedules) ->
      # Success
      $location.path "/schedules/#{schedules[0].id}"
    (schedule) ->
      # Error
      $scope.error = "Error"
