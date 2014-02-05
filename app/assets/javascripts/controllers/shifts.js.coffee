StaffScheduler.controller "ShiftsCtrl", @ShiftsCtrl = ($scope, $filter, $modal, Shifts, Schedules, Skills, Locations) ->
  $scope.modalTemplate = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#shifts").addClass "active"

  $scope.newShift = {is_mandatory: true}
  $scope.shifts = []
  $scope.shiftSources = [{
      color: "#7AB"
      textColor: "yellow"
      events: $scope.shifts
    }]

  date = new Date()
  d = date.getDate()
  m = date.getMonth()
  y = date.getFullYear()

  $scope.annotations = [
        {
          start: new Date(y, m, d, 13, 0)
          end: new Date(y, m, d, 15, 30)
          title: "My 1st annotation"
          cls: "open"
          color: "#777777" # optional
          background: "#eeeeff" # optional
        }
        {
          start: new Date(y, m, d + 1, 15, 0)
          end: new Date(y, m, d + 1, 16, 45)
          title: "On vacations"
          cls: "vacation"
          color: "#777777"
          background: "#eeeef0" # optional
        }
        {
          start: new Date(y, m, d + 1, 16, 0)
          end: new Date(y, m, d + 1, 18, 30)
          title: "Overlapping annotation"
          cls: "open"
          color: "#777777" # optional
          background: "#eeeedd" # optional
        }
        {
          # just minimal fields for annotation
          start: new Date(y, m, d - 1, 12, 0)
          end: new Date(y, m, d - 1, 14, 0)
        }
      ]

  $scope.fetchShifts = ->
    unless $scope.newShift.schedule_id is undefined or $scope.newShift.skill_id is undefined or $scope.newShift.location_id is undefined
      Shifts.query {
        schedule: $scope.newShift.schedule_id,
        skill: $scope.newShift.skill_id,
        location: $scope.newShift.location_id
      }, (result) ->
        # Success
        $scope.shifts.length = 0 # Preferred way of emptying a JS array
        $scope.annotations.length = 0
        angular.forEach result, (item) ->
          $scope.shifts.push item if item.id

        $scope.$apply
        $scope.shiftsCalendar.fullCalendar 'refetchEvents'

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


  $scope.schedules = Schedules.query (response) ->
    $scope.newShift.schedule_id = response[0].id
    $scope.$apply

  $scope.skills = Skills.query (response) ->
    $scope.newShift.skill_id = response[0].id
    $scope.$apply

  $scope.locations = Locations.query (response) ->
    $scope.newShift.location_id = response[0].id
    $scope.$apply

  $scope.$watch "newShift", (value) ->
    $scope.fetchShifts()
  , true
  
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
    annotations: $scope.annotations
    eventAfterRender: (event, element) -> # Here we customize the content and the color of the cell
      element.css('background-color','rgba(0,0,0,0.5)') if event.location_id is 2
      element.find('.fc-event-title').text('Custom title or content') if event.location_id is 3
