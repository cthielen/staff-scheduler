StaffScheduler.controller "DeleteCtrl", @DeleteCtrl = ($scope, $modalInstance, itemName, itemType) ->

  $scope.itemName = itemName
  $scope.itemType = itemType

  $scope.confirm = ->
    $modalInstance.close "delete"

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"
