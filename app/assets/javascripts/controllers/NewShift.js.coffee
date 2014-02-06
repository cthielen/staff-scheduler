StaffScheduler.controller "NewShiftCtrl", @NewShiftCtrl = ($scope, $modalInstance, newShift, Shifts, Schedules) ->
  $scope.newShifts = []
  $scope.error = null
  $scope.submitText = 'Create Shifts'
  
  Schedules.get {id: newShift.schedule_id},
    (schedule) ->
      # Success
      this_start_date = new Date(Date.parse(newShift.start_datetime))
      this_end_date = new Date(Date.parse(newShift.end_datetime))
      while this_end_date <= Date.parse(schedule.end_date)
        $scope.newShifts.push {
          is_mandatory: newShift.is_mandatory,
          schedule_id: newShift.schedule_id,
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
    _.each($scope.newShifts, (shift) ->
      $scope.submitText = 'Saving...'
      Shifts.save shift,
        (data) ->
          # Success
          index = $scope.newShifts.indexOf(shift)
          $scope.newShifts.splice(index,1)
          # If this is the last shift, close the modal
          if $scope.newShifts.length == 0
            $modalInstance.close newShift
          else if shift is $scope.newShifts[$scope.newShifts.length - 1] # Last shift in array
            $scope.error = 'Could not save some shifts, please try saving again'
            $scope.submitText = 'Try Again'
        (data) ->
          # Failure
          if shift is $scope.newShifts[$scope.newShifts.length - 1] # Last shift in array
            $scope.error = 'Could not save some shifts, please try saving again'
            $scope.submitText = 'Try Again'
    )

  $scope.close = ->
    $modalInstance.dismiss "cancel"
