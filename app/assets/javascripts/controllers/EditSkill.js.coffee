StaffScheduler.controller "EditSkillCtrl", @EditSkillCtrl = ($scope, $modalInstance, skill, Skills) ->
  $scope.skill = skill
  $scope.submitText = 'Update Skill'
  $scope.deleteText = 'Delete Skill'
  $scope.inProgress = false
  
  $scope.clearError = ->
    $scope.error = null

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'
    $scope.inProgress = true
    Skills.update $scope.skill,
      (data) ->
        # Success
        $modalInstance.close $scope.skill
      (data) ->
        # Failure
        $scope.error = 'Could not save skill, please try saving again'
        $scope.submitText = 'Try Again'
        $scope.inProgress = false

  $scope.confirmDelete = ->
    if $scope.deleteText is 'Delete Skill'
      $scope.deleteText = 'Are you sure?'
    else
      $scope.delete()

  $scope.delete = ->
    $scope.error = null
    $scope.deleteText = 'Deleting...'
    $scope.inProgress = true
    
    $scope.skill.is_disabled = true
    Skills.update $scope.skill,
      (data) ->
        # Success
        $modalInstance.close 'deleted'
      (data) ->
        # Failure
        $scope.error = 'Could not delete skill, please try deleting again'
        $scope.deleteText = 'Try Deleting Again'
        $scope.inProgress = false

  $scope.close = ->
    $modalInstance.dismiss "cancel"
