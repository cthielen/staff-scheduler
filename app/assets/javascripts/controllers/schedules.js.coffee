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
          console.log data
          $scope.schedules.splice(0, 0, data) # Adds the item on the top of the array
          $scope.addNew = false
          $scope.newSched['start_date'] = $scope.newSched['end_date'] = undefined
          $scope.clearError()
      , (data) ->
          # Error
          $scope.error = "Could not save changes"
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

  $scope.confirmDeleteSchedule = (schedule) ->
    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "Delete this schedule?"
        body: ->
          "#{schedule.name}"
        okButton: ->
          "Delete"
        showCancel: ->
          true

    modalInstance.result.then () ->
      Schedules.delete {id: schedule.id},
        (data) ->
          # Success
          $scope.deleteSchedule(schedule)
      , (data) ->
          # Error
          $scope.error = 'Could not delete schedule, please try deleting again'          

  $scope.deleteSchedule = (schedule) ->
    index = $scope.schedules.indexOf(schedule)
    $scope.schedules.splice(index,1)

  $scope.clearError = ->
    $scope.error = null
