StaffScheduler.controller "AvailabilityCtrl", @AvailabilityCtrl = ($scope, $filter, $modal, $location, Shifts, Schedules, Skills, Locations) ->
  $scope.modalTemplate = null
  $scope.error = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#availability").addClass "active"

  $scope.newShift = {is_mandatory: true}
  $scope.shifts = []
  $scope.shiftSources = [{
      color: "#7AB"
      textColor: "yellow"
      events: $scope.shifts
    }]

  $scope.fetchShifts = ->
    console.log 'Fetching shifts...'
    unless $scope.newShift.schedule_id is undefined or $scope.newShift.skill_id is undefined or $scope.newShift.location_id is undefined
      Shifts.query {
        schedule: $scope.newShift.schedule_id,
        skill: $scope.newShift.skill_id,
        location: $scope.newShift.location_id
      }, (result) ->
        # Success
        $scope.shifts.length = 0 # Preferred way of emptying a JS array
        angular.forEach result, (item) ->
          $scope.shifts.push item if item.id

        $scope.$apply
        $scope.shiftsCalendar.fullCalendar 'refetchEvents'

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
      $scope.init()
      # Reset $scope.newShift
      $scope.newShift = {
        is_mandatory: true,
        schedule_id: $scope.newShift.schedule_id,
        skill_id: $scope.newShift.skill_id,
        location_id: $scope.newShift.location_id
      }

  $scope.schedules = Schedules.query (response) ->
    if response.length
      $scope.newShift.schedule_id = response[0].id
      $scope.$apply
      $scope.init()
    else
      $scope.redirectTo('schedule','/schedules')

  $scope.skills = Skills.query (response) ->
    if response.length
      $scope.newShift.skill_id = response[0].id
      $scope.$apply
      $scope.init()

  $scope.locations = Locations.query (response) ->
    if response.length
      $scope.newShift.location_id = response[0].id
      $scope.$apply
      $scope.init()

  $scope.redirectTo = (type, path) ->
    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "No #{type} defined"
        body: ->
          "You are being redirected to create a #{type}"
        okButton: ->
          "OK"
        showCancel: ->
          false

    modalInstance.result.then () ->
      $location.path path

  # Initial fetch
  $scope.init = ->
    unless $scope.newShift.schedule_id is undefined or $scope.newShift.skill_id is undefined or $scope.newShift.location_id is undefined
      $scope.fetchShifts()
      $scope.currentSelectionsNames()

      # Change calendar date to the beginning of the schedule
      schedule = _.findWhere($scope.schedules, { id: $scope.newShift.schedule_id })
      scheduleStart = new Date(Date.parse(schedule.start_date))
      $scope.shiftsCalendar.fullCalendar 'gotoDate', scheduleStart.getFullYear(), scheduleStart.getMonth(), scheduleStart.getDate()
  
  $scope.confirmDeleteShift = (shift) ->
    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "Delete this shift?"
        body: ->
          "#{shift.start_datetime} - #{shift.end_datetime}"
        okButton: ->
          "Delete"
        showCancel: ->
          true

    modalInstance.result.then () ->
      $scope.deleteShift(shift)

  $scope.deleteShift = (shift) ->
    Shifts.delete {id: shift.id},
      (data) ->
        # Success
        index = $scope.shifts.indexOf(shift)
        $scope.shifts.splice(index,1)
        $scope.init()
    , (data) ->
        # Error
        $scope.error = "Error deleting shift '#{shift.start_datetime} - #{shift.end_datetime}'"

  $scope.currentSelectionsNames = ->
    skill = _.findWhere($scope.skills, { id: $scope.newShift.skill_id }).title
    location = _.findWhere($scope.locations, { id: $scope.newShift.location_id }).name
    schedule = _.findWhere($scope.schedules, { id: $scope.newShift.schedule_id }).name
    $scope.selectionsNames = {skill: skill, location: location, schedule: schedule}

  $scope.setSchedule = (schedule) ->
    $scope.newShift.schedule_id = schedule.id
    $scope.init()

  $scope.setSkill = (skill) ->
    $scope.newShift.skill_id = skill.id
    $scope.init()

  $scope.setLocation = (location) ->
    $scope.newShift.location_id = location.id
    $scope.init()

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
    select: $scope.createShift
    eventAfterRender: (event, element) -> # Here we customize the content and the color of the cell
      element.css('background-color','rgba(0,0,0,0.5)') if event.location_id is 2
      element.find('.fc-event-title').text('Custom title or content') if event.location_id is 3
    eventClick: (calEvent, jsEvent, view) ->
      $scope.confirmDeleteShift(calEvent)
