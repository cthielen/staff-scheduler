StaffScheduler.controller "PlanningCtrl", @PlanningCtrl = ($scope, $filter, $modal, Shifts, Schedules, Skills, Locations) ->
  $scope.error = null
  $(".navbar-nav li").removeClass "active"
  $("li#planning").addClass "active"

  
  $scope.newShiftAssignment = {}
  $scope.shifts = []
  $scope.shiftAssignments = []
  $scope.shiftAssignmentSources = [
    {
      color: "#7AB"
      textColor: "yellow"
      events: $scope.shiftAssignments
    },
    {
      color: "#000"
      textColor: "yellow"
      events: $scope.shifts
    }
  ]

  $scope.fetchShifts = ->
    console.log 'Fetching shifts...'
    unless $scope.newShiftAssignment.schedule_id is undefined or $scope.newShiftAssignment.skill_id is undefined or $scope.newShiftAssignment.location_id is undefined
      Shifts.query {
        schedule: $scope.newShiftAssignment.schedule_id,
        skill: $scope.newShiftAssignment.skill_id,
        location: $scope.newShiftAssignment.location_id
      }, (result) ->
        # Success
        $scope.shifts.length = 0 # Preferred way of emptying a JS array
        angular.forEach result, (item) ->
          item.isBackground = true
          item.editable = false
          $scope.shifts.push item if item.id

        $scope.$apply
        $scope.shiftsCalendar.fullCalendar 'refetchEvents'

  $scope.scheduleName = (sched) ->
    $filter('date')(sched.start_date, 'MM/dd/yyyy') + ' - ' + $filter('date')(sched.end_date, 'MM/dd/yyyy')
    # TODO: Change to 'name' of the schedule after adding a new column, and fall back to above if name is empty

  $scope.currentSelectionsNames = ->
    skill = _.findWhere($scope.skills, { id: $scope.newShiftAssignment.skill_id }).title
    location = _.findWhere($scope.locations, { id: $scope.newShiftAssignment.location_id }).name
    schedule = $scope.scheduleName(_.findWhere($scope.schedules, { id: $scope.newShiftAssignment.schedule_id }))
    $scope.selectionsNames = {skill: skill, location: location, schedule: schedule}

  $scope.schedules = Schedules.query (response) ->
    $scope.newShiftAssignment.schedule_id = response[0].id
    $scope.$apply
    $scope.init()

  $scope.skills = Skills.query (response) ->
    $scope.newShiftAssignment.skill_id = response[0].id
    $scope.$apply
    $scope.init()

  $scope.locations = Locations.query (response) ->
    $scope.newShiftAssignment.location_id = response[0].id
    $scope.$apply
    $scope.init()

  # Initial fetch
  $scope.init = ->
    unless $scope.newShiftAssignment.schedule_id is undefined or $scope.newShiftAssignment.skill_id is undefined or $scope.newShiftAssignment.location_id is undefined
      $scope.fetchShifts()
      $scope.currentSelectionsNames()
  
  $scope.clearError = ->
    $scope.error = null

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
