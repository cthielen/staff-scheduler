StaffScheduler.controller "NewShiftCtrl", @NewShiftCtrl = ($scope, $modalInstance, newShift, Shifts) ->
  $scope.newShift = newShift
  
  $scope.save = ->
    Shifts.save $scope.newShift, (data) ->
      $scope.newShift.start = $scope.newShift.start_datetime
      $scope.newShift.end = $scope.newShift.end_datetime
      $scope.newShift.title = $scope.newShift.location_id.toString()
      $modalInstance.close $scope.newShift

  $scope.close = ->
    $modalInstance.dismiss "cancel"