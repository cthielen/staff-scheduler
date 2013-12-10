StaffScheduler.controller "ShiftsCtrl", @ShiftsCtrl = ($scope, $filter, Shifts, Schedules) ->
  $scope.modalTemplate = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#shifts").addClass "active"

  $scope.newShift = {is_mandatory: true}
  Shifts.query(
    success = (data) ->
      $scope.shifts = data
  )
  Schedules.query(
    success = (data) ->
      $scope.schedules = data
      $scope.newShift.schedule_id = data[0].id
  )

  $scope.scheduleName = (sched) ->
    $filter('date')(sched.start_date, 'MM/dd/yyyy') + ' - ' + $filter('date')(sched.end_date, 'MM/dd/yyyy')
    # TODO: Change to 'name' of the schedule after adding a new column, and fall back to above if name is empty

  $scope.showModal = (template, startDate, endDate, allDay) ->
    $scope.newShift.start_datetime = startDate
    $scope.newShift.end_datetime = endDate

    $scope.modalTemplate = template
    $scope.modalVisible = true
    $scope.$apply() unless $scope.$$phase

  $scope.dismissModal = ->
    $scope.modalVisible = false

  $scope.createShift =  ->
    Shifts.save $scope.newShift, (data) ->
      $scope.shifts.push(data)
      $scope.modalVisible = false
