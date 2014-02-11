StaffScheduler.controller "ConfirmCtrl", @ConfirmCtrl = ($scope, $modalInstance, title, body, okButton, showCancel) ->

  $scope.title = title
  $scope.body = body
  $scope.okButton = okButton
  $scope.showCancel = showCancel

  $scope.confirm = ->
    $modalInstance.close "confirm"

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"
