StaffScheduler.controller "EditLocationCtrl", @EditLocationCtrl = ($scope, $modalInstance, location, Locations) ->
  $scope.location = location
  $scope.submitText = 'Update Location'
  $scope.deleteText = 'Delete Location'
  $scope.inProgress = false
  
  $scope.clearError = ->
    $scope.error = null

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'
    $scope.inProgress = true
    Locations.update $scope.location,
      (data) ->
        # Success
        $modalInstance.close $scope.location
      (data) ->
        # Failure
        $scope.error = 'Could not save location, please try saving again'
        $scope.submitText = 'Try Again'
        $scope.inProgress = false

  $scope.confirmDelete = ->
    if $scope.deleteText is 'Delete Location'
      $scope.deleteText = 'Are you sure?'
    else
      $scope.delete()

  $scope.delete = ->
    $scope.error = null
    $scope.deleteText = 'Deleting...'
    $scope.inProgress = true
    
    $scope.location.is_disabled = true
    Locations.update $scope.location,
      (data) ->
        # Success
        $modalInstance.close 'deleted'
      (data) ->
        # Failure
        $scope.error = 'Could not delete location, please try saving again'
        $scope.deleteText = 'Try Deleting Again'
        $scope.inProgress = false

  $scope.close = ->
    $modalInstance.dismiss "cancel"