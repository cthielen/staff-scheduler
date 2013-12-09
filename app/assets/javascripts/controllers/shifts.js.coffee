StaffScheduler.controller "ShiftsCtrl", @ShiftsCtrl = ($scope, $filter, Shifts, Schedules) ->
  $scope.modalTemplate = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#shifts").addClass "active"

  $scope.shift = []
  $scope.schedules = Schedules.query(
    success = (data) ->
      $scope.shift.schedule = data[0]
    )

  $scope.scheduleName = (sched) ->
    $filter('date')(sched.start_date, 'MM/dd/yyyy') + ' - ' + $filter('date')(sched.end_date, 'MM/dd/yyyy')
    # TODO: Change to 'name' of the schedule after adding a new column, and fall back to above if name is empty

  $scope.showSelected = ->
    console.log $scope.shift.schedule

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
