StaffScheduler.controller "SchedulesCtrl", @SchedulesCtrl = ($scope, $routeParams, $modal, Schedules) ->
  $(".navbar-nav li").removeClass "active"
  $("li#schedules").addClass "active"
  $scope.error = null
    
  $scope.schedules = Schedules.query()

  $scope.toggleNewSchedule = ->
    $scope.addNew = (if $scope.addNew then false else true)

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

  $scope.editSchedule = (schedule) ->
    modalInstance = $modal.open
      templateUrl: "/assets/partials/editSchedule.html"
      controller: EditScheduleCtrl
      resolve:
        schedule: ->
          schedule

    modalInstance.result.then (state) ->
      if state is 'deleted'
        $scope.deleteSchedule schedule
      else
        $scope.schedules = Schedules.query()

  $scope.deleteSchedule = (schedule) ->
    index = $scope.schedules.indexOf(schedule)
    $scope.schedules.splice(index,1)

  $scope.clearError = ->
    $scope.error = null
