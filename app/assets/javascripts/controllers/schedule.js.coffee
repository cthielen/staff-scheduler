StaffScheduler.controller "ScheduleCtrl", @ScheduleCtrl = ($scope) ->
  $scope.modalTemplate = null
  $(".navbar-nav li").removeClass "active"
  $("li#schedule").addClass "active"
  $scope.dismissModal = ->
    $scope.modalVisible = false