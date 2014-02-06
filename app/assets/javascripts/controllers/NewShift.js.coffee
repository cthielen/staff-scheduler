StaffScheduler.controller "NewShiftCtrl", @NewShiftCtrl = ($scope, $modalInstance, newShift, Shifts, Schedules) ->
  $scope.newShifts = []
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

  $scope.save = ->
    _.each($scope.newShifts, (shift) ->
      Shifts.save shift, (data) ->
        # If this is the last shift, close the modal
        if shift is $scope.newShifts[$scope.newShifts.length - 1]
          newShift.start = newShift.start_datetime
          newShift.end = newShift.end_datetime
          newShift.title = newShift.location_id.toString()
          $modalInstance.close newShift
    )

  $scope.close = ->
    $modalInstance.dismiss "cancel"
