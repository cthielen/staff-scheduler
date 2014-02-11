StaffScheduler.controller "SchedulesCtrl", @SchedulesCtrl = ($scope, $routeParams, Schedules) ->
  $(".navbar-nav li").removeClass "active"
  $("li#schedules").addClass "active"
  $scope.error = null
    
  $scope.schedules = Schedules.query()

  $scope.newSchedule = ->
    $scope.addNew = true

  $scope.createSchedule = ->
    # Submit only if all fields are filled
    unless ($scope.newSched['start_date'] is undefined or $scope.newSched['end_date'] is undefined)
      Schedules.save $scope.newSched,
        (data) ->
          # Success
          $scope.schedules.splice(0, 0, data) # Adds the item on the top of the array
          $scope.addNew = false
          $scope.newSched['start_date'] = $scope.newSched['end_date'] = undefined
          $scope.clearError()
      , (data) ->
          # Error
          $scope.error = "Could not save changes"
          console.log data
          # Display errors
          _.each(data.data , (e,i) ->
              $scope.error = $scope.error + "<li>#{i}: #{e}</li>"
            )

  $scope.clearError = ->
    $scope.error = null
