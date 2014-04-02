StaffScheduler.controller "PlannerCtrl", @PlannerCtrl = ($scope, $modal, $timeout, $location, $routeParams, Schedules, Employees, CurrentEmployee, Skills, Locations, Shifts, Availabilities, Assignments, LocationSkillCombinations, EmployeeSchedules) ->

  ## Initializations
  $scope.locationSkillCombinations = []
  $scope.loading = 0
  $scope.selections = {
    lsCombination: 0,
    layer: 0,
    tab: 0
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

  # Fetch Schedule
  if $routeParams.id
    $scope.schedule = Schedules.get {id: $routeParams.id},
      (schedule) ->
        # Success
        CurrentEmployee.query {},
          (current) ->
            # Success
            $scope.currentEmployee = current
            $scope.selections.layer = 1 unless current.isManager
            # Render the calendar after setting the current employee to resize the days properly
            $timeout(->
              $scope.plannerCalendar.fullCalendar 'render'
            , 10) # Delaying the render was necessary: http://goo.gl/lkHOXD

            # Fetch Employees
            $scope.employees = Employees.query {},
              (employees) ->
                # Success
                if employees.length
                  $scope.selections.employee = if current then _.findWhere(employees, {id: current.id}) else employees[0]
                  $scope.populateEvents()
                else if !$scope.modalOpen
                  $scope.modalOpen = true
                  $scope.redirectTo('employee','/employees')
              (employees) ->
                # Error
                $scope.error = "Error loading employees!"
          (current) ->
            # Error
            $scope.error = "Error fetching current employee!"
      (schedule) ->
        # Error
        $scope.error = "Error loading schedule!"

    # Fetch Location/Skill combinations
    LocationSkillCombinations.then (combinations) ->
      if combinations.length
        $scope.locationSkillCombinations = combinations
        $scope.populateEvents()
      else if !$scope.modalOpen
        $scope.modalOpen = true
        $scope.redirectTo('skill/location','/employees')

  ## Construct the calendar when selections change
  $scope.$watch "selections", (selections) ->
    $scope.populateEvents()
  , true

  $scope.populateEvents = ->
    switch $scope.selections.layer
      when 0
        $scope.fetchEvents(Assignments,false)
        $scope.fetchEvents(Shifts,true)
      when 1
        # Fetch EmployeeSchedule
        EmployeeSchedules.query {
          employee: $scope.currentEmployee.id,
          schedule: $scope.schedule.id
        },
          (data) ->
            # Success
            $scope.employeeSchedule = data[0]

        $scope.fetchEvents(Availabilities,false)
        $scope.fetchEvents(Shifts,true)
      when 2
        $scope.fetchEvents(Shifts,false)
        $scope.fetchEvents(Shifts,true,true)

  $scope.constructParams = ->
    switch $scope.selections.tab
      when 0
        {
          schedule: $scope.schedule.id,
          skill: $scope.locationSkillCombinations[$scope.selections.lsCombination].skill.id,
          location: $scope.locationSkillCombinations[$scope.selections.lsCombination].location.id
        }
      when 1
        {
          schedule: $scope.schedule.id,
          employee: $scope.selections.employee.id
        }

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
      unless $scope.locationSkillCombinations.length is 0
        $scope.loading++
        source.query $scope.constructParams(), (result) ->
          # Success
          $scope.loading--
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
        # Remove from calendar events
        index = $scope.frontEvents.indexOf(event)
        $scope.frontEvents.splice(index,1)
        # Remove from employee availabilities
        index = $scope.selections.employee.availabilities.indexOf(event)
        $scope.selections.employee.availabilities.splice(index,1)

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
    schedule = _.findWhere($scope.schedule, { id: schedule_id })
    modalInstance = $modal.open
      templateUrl: "/assets/partials/editSchedule.html"
      controller: EditScheduleCtrl
      resolve:
        schedule: ->
          schedule

    modalInstance.result.then (state) ->
      $scope.modalOpen = false
      if state is 'deleted'
        $scope.deleteSchedule schedule
      else if state is 'new'
        $scope.init()
      else
        $scope.schedule = Schedules.query()

  $scope.createShifts = (start, end) ->
    currentLS = $scope.locationSkillCombinations[$scope.selections.lsCombination]
    $scope.clearError()
    newShifts = $scope.calculateRepetitions({
      is_mandatory: true,
      start_datetime: start,
      end_datetime: end,
      schedule_id: $scope.schedule.id,
      skill_id: currentLS.skill.id,
      location_id: currentLS.location.id
    })
    $scope.schedule.shifts_attributes = $scope.schedule.shifts.concat(newShifts)
    Schedules.update $scope.schedule,
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
      schedule_id: $scope.schedule.id,
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
    while this_end_date <= Date.parse($scope.schedule.end_date)
      copy = angular.copy(model)
      copy.start_datetime = new Date(this_start_date)
      copy.end_datetime = new Date(this_end_date)
      repetitions.push copy

      this_start_date.setDate(this_start_date.getDate()+7)
      this_end_date.setDate(this_end_date.getDate()+7)
    repetitions

  $scope.changeState = () ->
    $scope.loading++
    switch $scope.selections.layer
      when 0
        # assignments
        $scope.schedule.state = 4
        Schedules.update $scope.schedule,
          (data) ->
            # Success
            $scope.schedule = data
            $scope.loading--
          (data) ->
            # Failure
            $scope.schedule.state = 3
            $scope.error = 'Could not mark as complete, please try again'
            $scope.loading--
      when 1
        # availabilities
        $scope.employeeSchedule.availability_submitted = true
        EmployeeSchedules.update $scope.employeeSchedule,
          (data) ->
            # Success
            $scope.loading--
        , (data) ->
            # Error
            $scope.error = 'Could not mark as complete, please try again'
            $scope.loading--
      when 2
        $scope.schedule.state = 2
        Schedules.update $scope.schedule,
          (data) ->
            # Success
            $scope.schedule = data
            $scope.loading--
          (data) ->
            # Failure
            $scope.schedule.state = 1
            $scope.error = 'Could not mark as complete, please try again'
            $scope.loading--

  $scope.readyToSubmit = () ->
    loading = $scope.loading > 0
    switch $scope.selections.layer
      when 0
        # assignments
        validState = $scope.schedule and ($scope.schedule.state == 3)
      when 1
        # availabilities
        validState = ($scope.employeeSchedule and !$scope.employeeSchedule.availability_submitted)
      when 2
        validState = $scope.schedule and ($scope.schedule.state == 1)

    validState and !loading

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
      $scope.modalOpen = false
      $location.path path

  $scope.changeTab = (tab) ->
    $scope.selections.tab = tab

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
