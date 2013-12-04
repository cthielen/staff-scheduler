StaffScheduler.controller "ScheduleCtrl", @ScheduleCtrl = ($scope, Shifts) ->
  $scope.modalTemplate = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#schedule").addClass "active"

  $scope.showModal = (template) ->
    $scope.modalTemplate = template
    $scope.modalVisible = true
    $scope.$apply() unless $scope.$$phase

  $scope.dismissModal = ->
    $scope.modalVisible = false

  $scope.createShift = (newShft) ->
    Shifts.save newShft, (data) ->
      $scope.shifts.push(data);
      $scope.modalVisible = false
