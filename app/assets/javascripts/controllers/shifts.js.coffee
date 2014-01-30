StaffScheduler.controller "ShiftsCtrl", @ShiftsCtrl = ($scope, $filter, $modal, Schedules, Skills, Locations) ->
  $scope.modalTemplate = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#shifts").addClass "active"

  $scope.newShift = {is_mandatory: true}
  
  $scope.shifts =
    color: "#7AB"
    textColor: "yellow"
    url: "/shifts.json"
  $scope.shiftSources = [$scope.shifts]
  
  $scope.schedules = []
  Schedules.query (response) ->
    angular.forEach response, (item) ->
      $scope.schedules.push item if item.id
    $scope.newShift.schedule_id = response[0].id
    $scope.$apply

  $scope.skills = []
  Skills.query (response) ->
    angular.forEach response, (item) ->
      $scope.skills.push item if item.id
    $scope.newShift.skill_id = response[0].id
    $scope.$apply

  $scope.locations = []
  Locations.query (response) ->
    angular.forEach response, (item) ->
      $scope.locations.push item if item.id
    $scope.newShift.location_id = response[0].id
    $scope.$apply

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
      # Reset $scope.newShift and refetch events
      $scope.newShift = {is_mandatory: true}
      $scope.shiftsCalendar.fullCalendar 'refetchEvents'

  # config calendar 
  $scope.uiConfig = calendar:
    weekends: false
    contentHeight: 450
    defaultView: "agendaWeek"
    selectable: true
    allDayDefault: false
    allDaySlot: false
    slotEventOverlap: false
    minTime: 7
    maxTime: 18
    header:
      left: "prev,next"
      center: "title"
      right: "today agendaWeek,agendaDay"
      ignoreTimezone: false
    select: $scope.createShift
    eventAfterRender: (event, element) -> # Here we customize the content and the color of the cell
      element.css('background-color','rgba(0,0,0,0.5)') if event.location_id is 2
      element.find('.fc-event-title').text('Custom title or content') if event.location_id is 3

  $scope.$watch "shiftsCalendar", (value) ->
    value.fullCalendar 'rerenderEvents'