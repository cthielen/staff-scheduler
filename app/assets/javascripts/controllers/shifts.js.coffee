StaffScheduler.controller "ShiftsCtrl", @ShiftsCtrl = ($scope, $filter, $modal, Shifts, Schedules) ->
  $scope.modalTemplate = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#shifts").addClass "active"

  $scope.newShift = {is_mandatory: true}
  
  $scope.shifts = []
  
  Shifts.query (response) ->
    angular.forEach response, (shift) ->
      $scope.shifts.push shift if shift.id

  $scope.schedules = []
  Schedules.query (response) ->
    angular.forEach response, (item) ->
      $scope.schedules.push item if item.id
    $scope.newShift.schedule_id = response[0].id

  $scope.scheduleName = (sched) ->
    $filter('date')(sched.start_date, 'MM/dd/yyyy') + ' - ' + $filter('date')(sched.end_date, 'MM/dd/yyyy')
    # TODO: Change to 'name' of the schedule after adding a new column, and fall back to above if name is empty

  $scope.createShift = (startDate, endDate) ->
    $scope.newShift.start_datetime = startDate
    $scope.newShift.end_datetime = endDate

    modalInstance = $modal.open
      templateUrl: "/assets/partials/newShift.html"
      controller: NewShiftCtrl
      resolve:
        newShift: ->
          $scope.newShift

    modalInstance.result.then (shift) ->
      # Add the shift to the array
      $scope.newShift = {is_mandatory: true}
      $scope.shifts.push shift
