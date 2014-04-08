StaffScheduler.controller "ScheduleRedirectCtrl", @ScheduleRedirectCtrl = ($scope, $location, Schedules) ->

  Schedules.query { active: true },
    (schedules) ->
      # Success
      if schedules.length
        $location.path "/schedules/#{schedules[0].id}"
      else
        $location.path "/schedules/new"
    (schedule) ->
      # Error
      $scope.error = "Error"
