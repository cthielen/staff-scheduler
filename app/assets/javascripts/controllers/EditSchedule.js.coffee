StaffScheduler.controller "EditScheduleCtrl", @EditScheduleCtrl = ($scope, $modalInstance, schedule, Schedules) ->
  $scope.schedule = schedule
  $scope.submitText = 'Update Schedule'
  $scope.deleteText = 'Delete Schedule'
  $scope.inProgress = false
  
  $scope.clearError = ->
    $scope.error = null

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'
    $scope.inProgress = true
    Schedules.update $scope.schedule,
      (data) ->
        # Success
        $modalInstance.close $scope.schedule
      (data) ->
        # Failure
        $scope.error = 'Could not save schedule, please try saving again'
        $scope.submitText = 'Try Again'
        $scope.inProgress = false

  $scope.confirmDelete = ->
    if $scope.deleteText is 'Delete Schedule'
      $scope.deleteText = 'Are you sure?'
    else
      $scope.delete()

  $scope.delete = ->
    $scope.error = null
    $scope.deleteText = 'Deleting...'
    $scope.inProgress = true
    
    Schedules.delete {id: schedule.id},
      (data) ->
        # Success
        $modalInstance.close 'deleted'
    , (data) ->
        # Error
        $scope.error = 'Could not delete schedule, please try saving again'
        $scope.deleteText = 'Try Deleting Again'
        $scope.inProgress = false

  $scope.close = ->
    $modalInstance.dismiss "cancel"
