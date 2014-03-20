StaffScheduler.controller "PlannerCtrl", @PlannerCtrl = ($scope, $modal, $timeout, Schedules, Employees, CurrentEmployee, Skills, Locations, Shifts, Availabilities, Assignments, LocationSkillCombinations) ->

  ## Initializations
  $scope.locationSkillCombinations = []
  $scope.selections = {
    lsCombination: 0,
    layer: 0
  }
  $scope.frontEvents = []
  $scope.backEvents = []
  $scope.eventSources = [
    {
      color: "#7AB"
      textColor: "yellow"
      events: $scope.frontEvents
    },
    {
      color: "#999"
      events: $scope.backEvents
    }
  ]

  CurrentEmployee.query (current) ->
    $scope.currentEmployee = current

    $scope.employees = Employees.query (response) ->
      if response.length
        $scope.selections.employee = if current then _.findWhere(response, {id: current.id}) else response[0]

    $timeout(->
      $scope.plannerCalendar.fullCalendar 'render'
    , 10) # Delaying the render was necessary: http://goo.gl/lkHOXD

  ## Construct the calendar when selections change
  $scope.$watch "selections", (selections) ->
    $scope.populateEvents()
  , true

  ## Fetching Data
  # Fetch Location/Skill combinations
  LocationSkillCombinations.then (combinations) ->
    $scope.locationSkillCombinations = combinations
    $scope.populateEvents()

  # Fetch Schedules
  $scope.schedules = Schedules.query (response) ->
    if response.length
      $scope.selections.schedule = response[0]
      $scope.populateEvents()
    else
      $scope.redirectTo('schedule','/schedules')

  $scope.populateEvents = ->
    switch $scope.selections.layer
      when 0
        $scope.fetchEvents(Assignments,false)
        $scope.fetchEvents(Shifts,true)
      when 1
        $scope.fetchEvents(Availabilities,false)
        $scope.fetchEvents(Shifts,true)
      when 2
        $scope.fetchEvents(Shifts,false)
        $scope.fetchEvents(Shifts,true,true)

  # Fetching events
  # fetchEvents(
  #     source: the angular service to perform the .query call on
  #     isBackground: Boolean, whether a background event (true), or a main event (false)
  #     clearEvents: Optional Boolean, clears the array of background or main events if set to true
  # )
  $scope.fetchEvents = (source, isBackground, clearEvents) ->
    clearEvents ?= false
    events = (if isBackground then $scope.backEvents else $scope.frontEvents)
    if clearEvents
      events.length = 0
    else
      unless $scope.locationSkillCombinations.length is 0 or $scope.selections.schedule is undefined
        source.query {
          schedule: $scope.selections.schedule.id,
          skill: $scope.locationSkillCombinations[$scope.selections.lsCombination].skill.id,
          location: $scope.locationSkillCombinations[$scope.selections.lsCombination].location.id
        }, (result) ->
          # Success
          events.length = 0 # Preferred way of emptying a JS array
          angular.forEach result, (item) ->
            item.isBackground = true if isBackground
            events.push item if item.id

          $scope.$apply() if !$scope.$$phase
          $scope.plannerCalendar.fullCalendar 'refetchEvents'

  $scope.confirmDelete = (event) ->
    switch $scope.selections.layer
      when 0
        source = Assignments
        type = "Assignment"
      when 1
        source = Availabilities
        type = "Availability"
      when 2
        source = Shifts
        type = "Shift"

    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "Delete this #{type}?"
        body: ->
          "#{event.title}: #{moment(event.start).format('MMM Do YY, h:mm a')} - #{moment(event.end).format('h:mm a')}"
        okButton: ->
          "Delete"
        showCancel: ->
          true

    modalInstance.result.then () ->
      $scope.deleteEvent(source, event, type )

  $scope.deleteEvent = (source, event, type ) ->
    source.delete {id: event.id},
      (data) ->
        # Success
        index = $scope.frontEvents.indexOf(event)
        $scope.frontEvents.splice(index,1)
        $scope.populateEvents()
    , (data) ->
        # Error
        $scope.error = "Error deleting #{type} '#{event.start_datetime} - #{event.end_datetime}'"

  $scope.createAssignmentDialog = (start, end) ->
    $scope.clearError()
    shift = _.find $scope.backEvents, (e) ->
      e.start <= start and e.end >= end

    if shift
      newAssignment = {
        shift_id: shift.id,
        start_datetime: start,
        end_datetime: end
      }

      modalInstance = $modal.open
        templateUrl: "/assets/partials/newAssignment.html"
        controller: NewAssignmentCtrl
        resolve:
          newAssignment: ->
            newAssignment

      modalInstance.result.then (assignment) ->
        $scope.populateEvents()
    else
      $scope.error = "Assignments must fall within a defined shift"
      $scope.$apply() if !$scope.$$phase

  $scope.editSchedule = (schedule_id) ->
    schedule = _.findWhere($scope.schedules, { id: schedule_id })
    modalInstance = $modal.open
      templateUrl: "/assets/partials/editSchedule.html"
      controller: EditScheduleCtrl
      resolve:
        schedule: ->
          schedule

    modalInstance.result.then (state) ->
      if state is 'deleted'
        $scope.deleteSchedule schedule
      else
        $scope.schedules = Schedules.query()

  $scope.createShifts = (start, end) ->
    currentLS = $scope.locationSkillCombinations[$scope.selections.lsCombination]
    $scope.clearError()
    newShifts = $scope.calculateRepetitions({
      is_mandatory: true,
      start_datetime: start,
      end_datetime: end,
      schedule_id: $scope.selections.schedule.id,
      skill_id: currentLS.skill.id,
      location_id: currentLS.location.id
    })
    $scope.selections.schedule.shifts_attributes = $scope.selections.schedule.shifts.concat(newShifts)
    Schedules.update $scope.selections.schedule,
      (data) ->
        # Success
        $scope.populateEvents()
      (data) ->
        # Failure
        $scope.error = 'Could not save shifts, please try saving again'
        # Display specific errors
        _.each(data.data , (e,i) ->
            $scope.error = $scope.error + "<li>#{i}: #{e}</li>"
          )

  $scope.createAvailabilities = (start, end) ->
    $scope.clearError()
    newAvailabilities = $scope.calculateRepetitions({
      start_datetime: start,
      end_datetime: end,
      schedule_id: $scope.selections.schedule.id,
    })
    $scope.selections.employee.employee_availabilities_attributes = $scope.selections.employee.availabilities.concat(newAvailabilities)
    Employees.update $scope.selections.employee,
      (data) ->
        # Success
        $scope.populateEvents()
      (data) ->
        # Failure
        $scope.error = 'Could not save availabilities, please try saving again'
        # Display specific errors
        _.each(data.data , (e,i) ->
            $scope.error = $scope.error + "<li>#{i}: #{e}</li>"
          )

  $scope.calculateRepetitions = (model) ->
    repetitions = []
    this_start_date = new Date(Date.parse(model.start_datetime))
    this_end_date = new Date(Date.parse(model.end_datetime))
    while this_end_date <= Date.parse($scope.selections.schedule.end_date)
      copy = angular.copy(model)
      copy.start_datetime = new Date(this_start_date)
      copy.end_datetime = new Date(this_end_date)
      repetitions.push copy

      this_start_date.setDate(this_start_date.getDate()+7)
      this_end_date.setDate(this_end_date.getDate()+7)
    repetitions

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

  $scope.clearError = ->
    $scope.error = null

  ## config calendar
  $scope.uiConfig = calendar:
    weekends: false
    contentHeight: 350
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
    select: (startDate, endDate, allDay) ->
      switch $scope.selections.layer
        when 0
          $scope.createAssignmentDialog(startDate, endDate)
        when 1
          $scope.createAvailabilities(startDate, endDate)
        when 2
          $scope.createShifts(startDate, endDate)
    eventAfterRender: (event, element) -> # Here we customize the content and the color of the cell
      element.find('.fc-event-inner').css('display','none') if event.isBackground
    eventClick: (calEvent, jsEvent, view) ->
      $scope.confirmDelete(calEvent)
