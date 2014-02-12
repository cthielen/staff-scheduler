StaffScheduler.controller "NewShiftCtrl", @NewShiftCtrl = ($scope, $modalInstance, newShift, Shifts, Schedules) ->
  $scope.newShifts = []
  $scope.error = null
  $scope.submitText = 'Create Shifts'
  
  Schedules.get {id: newShift.schedule_id},
    (schedule) ->
      # Success
      console.log schedule
      $scope.schedule = schedule
      this_start_date = new Date(Date.parse(newShift.start_datetime))
      this_end_date = new Date(Date.parse(newShift.end_datetime))
      while this_end_date <= Date.parse(schedule.end_date)
        $scope.newShifts.push {
          is_mandatory: newShift.is_mandatory,
          location_id: newShift.location_id,
          skill_id: newShift.skill_id,
          start_datetime: new Date(this_start_date),
          end_datetime: new Date(this_end_date)
        }
        this_start_date.setDate(this_start_date.getDate()+7)
        this_end_date.setDate(this_end_date.getDate()+7)
  , (data) ->
      # TODO: Error

  $scope.removeShift = (index) ->
    $scope.newShifts.splice(index,1)

  $scope.clearError = ->
    $scope.error = null

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'
    $scope.schedule.shifts_attributes = $scope.schedule.shifts.concat($scope.newShifts)
    Schedules.update $scope.schedule,
      (data) ->
        # Success
        $modalInstance.close newShift
      (data) ->
        # Failure
        $scope.error = 'Could not save shifts, please try saving again'
        $scope.submitText = 'Try Again'
        # Display specific errors
        _.each(data.data , (e,i) ->
            $scope.error = $scope.error + "<li>#{e}</li>"
          )

  $scope.close = ->
    $modalInstance.dismiss "cancel"
