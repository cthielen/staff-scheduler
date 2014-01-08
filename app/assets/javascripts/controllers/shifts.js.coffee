StaffScheduler.controller "ShiftsCtrl", @ShiftsCtrl = ($scope, $filter, $modal, Shifts, Schedules) ->

  $scope.viewDate = new Date()
  $scope.viewWeek = []
  $scope.getWeek = (d) ->
    $scope.viewWeek = []
    d = new Date(d)
    day = d.getDay()
    diff = d.getDate() - day + ((if day is 0 then -6 else 1)) # Mon = 1
    $scope.viewWeek.push new Date(d.setDate(i)) for i in [diff .. diff+4]
    $scope.viewWeek
  
  $scope.getWeek($scope.viewDate)
  $scope.$watch "viewDate", (value, old) ->
    $scope.getWeek(value)
  , true
    
  # Set the hours array
  $scope.$watch "viewDate", (value, old) ->
    minHr = 7
    maxHr = 18
    $scope.step = 0.5
    $scope.hours = []
    while minHr < maxHr
      hour = new Date($scope.viewDate)
      diff = hour.getDate() - hour.getDay() + ((if hour.getDay() is 0 then -6 else 1)) # Mon = 1
      hour =  new Date(hour.setDate(diff))
      hour.setSeconds(0)
      hour.setHours(minHr)
      hour.setMinutes(minHr%1*60)
      $scope.hours.push hour
      minHr+=$scope.step
  , true

  $scope.previousWeek = ->
    $scope.viewDate.setDate($scope.viewDate.getDate() - 7)
  
  $scope.nextWeek = ->
    $scope.viewDate.setDate($scope.viewDate.getDate() + 7)
  
  currentCol = undefined
  $("#selectable").selectable
    filter: "td"
    stop: (event, ui) ->
      currentCol = undefined
      selection = _.map( $('#selectable td.ui-selected'), (i) ->
        [$(i).closest('tr').attr('data-row'),$(i).closest('td').attr('data-col')] )
      if selection.length > 0
        startDateSelected = new Date(selection[0][0])
        startDateSelected.setDate(startDateSelected .getDate() + parseInt(selection[0][1]))
        endDateSelected = new Date(selection[selection.length-1][0])
        endDateSelected.setDate(endDateSelected  .getDate() + parseInt(selection[0][1]))
        $scope.createShift(startDateSelected,endDateSelected)

    selecting: (event, ui) ->
      currentCol = $(ui.selecting).attr("data-col") if currentCol is undefined
      # Exclude columns with no data-col attribute
      $(ui.selecting).removeClass('ui-selecting') if $(ui.selecting).attr("data-col") is undefined
      # Prevent highlighting the cell if it is in a different column
      $(ui.selecting).removeClass('ui-selecting') unless $(ui.selecting).attr("data-col") is currentCol


  $scope.modalTemplate = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#shifts").addClass "active"

  $scope.newShift = {is_mandatory: true}
  
  $scope.shifts = []
  $scope.shiftSources = [$scope.shifts]
  
  Shifts.query (response) ->
    angular.forEach response, (item) ->
      $scope.shifts.push item  if item.id

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
      $scope.shifts.push shift
      # Render the shift on the calendar
      $scope.shiftsCalendar.fullCalendar "renderEvent", shift, true
