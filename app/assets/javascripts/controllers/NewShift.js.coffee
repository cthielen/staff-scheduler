StaffScheduler.controller "NewShiftCtrl", @NewShiftCtrl = ($scope, $modalInstance, shifts, newShift, Shifts) ->
  $scope.shifts = shifts
  $scope.newShift = newShift
  
  $scope.save = ->
    Shifts.save $scope.newShift, (data) ->
      $scope.shifts.push(data)
      $modalInstance.close $scope.shifts

  $scope.close = ->
    $modalInstance.dismiss "cancel"