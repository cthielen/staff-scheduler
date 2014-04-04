StaffScheduler.controller "EditScheduleCtrl", @EditScheduleCtrl = ($scope, $routeParams, $location, CurrentEmployee, Schedules) ->
  $scope.inProgress = false
  $scope.deleteText = 'Delete Schedule'

  $scope.getCurrentEmployee = ->
    CurrentEmployee.query {},
      (current) ->
        # Success
        $scope.currentEmployee = current
        $scope.schedule.organization_id = $scope.currentEmployee.organizations[0].id
      (current) ->
        # Error
        $scope.error = "Error fetching current employee!"

  $scope.clearError = ->
    $scope.error = null

  $scope.cancel = ->
    if $scope.schedule.id
      $location.path "/schedules/#{$scope.schedule.id}"
    else
      $location.path "/"

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'
    $scope.inProgress = true
    if $scope.schedule.id
      Schedules.update $scope.schedule,
        (data) ->
          # Success
          $location.path "/schedules/#{data.id}"
        (data) ->
          # Failure
          $scope.error = 'Could not save schedule, please try saving again'
          $scope.submitText = 'Try Again'
          $scope.inProgress = false
    else
      Schedules.save $scope.schedule,
        (data) ->
          # Success
          $location.path "/schedules/#{data.id}"
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

    Schedules.delete {id: $scope.schedule.id},
      (data) ->
        # Success
        $location.path "/"
    , (data) ->
        # Error
        $scope.error = 'Could not delete schedule, please try saving again'
        $scope.deleteText = 'Try Deleting Again'
        $scope.inProgress = false

  if $routeParams.id
    Schedules.get {id: $routeParams.id},
      (schedule) ->
        # Success
        $scope.schedule = schedule
        $scope.getCurrentEmployee()
        $scope.submitText = 'Update Schedule'
        $scope.actionText = 'Edit'
      (schedule) ->
        # Error
        $scope.error = "Error loading schedule"
  else
    $scope.schedule = {}
    $scope.getCurrentEmployee()
    $scope.submitText = 'Create Schedule'
    $scope.actionText = 'New Schedule'
