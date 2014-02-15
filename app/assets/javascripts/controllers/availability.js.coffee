StaffScheduler.controller "AvailabilityCtrl", @AvailabilityCtrl = ($scope, $filter, $modal, $location, Shifts, Schedules, Skills, Locations, Employees, Availabilities) ->
  $scope.modalTemplate = null
  $scope.error = null
  $scope.modalVisible = false
  $(".navbar-nav li").removeClass "active"
  $("li#availability").addClass "active"

  $scope.newAvailability = {}
  $scope.newAvailabilities = []
  $scope.availabilities = []
  $scope.shifts = []
  $scope.calSources = [{
      color: "#7AB"
      events: $scope.availabilities
    },{
      color: "#CCC"
      events: $scope.shifts
    }
  ]

  $scope.schedules = Schedules.query (response) ->
    if response.length
      $scope.newAvailability.schedule_id = response[0].id
      $scope.$apply
      $scope.init()
    else
      $scope.redirectTo('schedule','/schedules')

  # Get the logged in employee
  $scope.error = null
  Employees.get {id: 45}, # FIX ME: this needs to be a service that grabs current logged in employee (Employees.current)
    (data) ->
      # Success
      $scope.employee = data
  , (data) ->
      # Error
      $scope.error = 'Could not query current user'

  $scope.fetchAvailabilities = ->
    unless $scope.newAvailability.schedule_id is undefined
      console.log 'Fetching availabilities...'
      Availabilities.query {
        schedule: $scope.newAvailability.schedule_id
      }, (result) ->
        # Success
        $scope.availabilities.length = 0 # Preferred way of emptying a JS array
        angular.forEach result, (item) ->
          $scope.availabilities.push item if item.id

        console.log $scope.availabilities
        $scope.$apply
        $scope.availabilityCalendar.fullCalendar 'refetchEvents'

  $scope.fetchShifts = ->
    unless $scope.newAvailability.schedule_id is undefined
      console.log 'Fetching shifts...'
      Shifts.query {
        schedule: $scope.newAvailability.schedule_id
      }, (result) ->
        # Success
        $scope.shifts.length = 0 # Preferred way of emptying a JS array
        angular.forEach result, (item) ->
          item.isBackground = true
          $scope.shifts.push item if item.id

        $scope.$apply
        $scope.availabilityCalendar.fullCalendar 'refetchEvents'

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
    unless $scope.newAvailability.schedule_id is undefined
      $scope.fetchAvailabilities()
      $scope.fetchShifts()
      $scope.setScheduleName()

      # Change calendar date to the beginning of the schedule
      schedule = _.findWhere($scope.schedules, { id: $scope.newAvailability.schedule_id })
      scheduleStart = new Date(Date.parse(schedule.start_date))
  
  $scope.createAvailability = (startDate, endDate) ->
    $scope.newAvailability.start_datetime = startDate
    $scope.newAvailability.end_datetime = endDate

    # Calculate the repeated times within selected schedule
    this_start_date = new Date(Date.parse($scope.newAvailability.start_datetime))
    this_end_date = new Date(Date.parse($scope.newAvailability.end_datetime))
    while this_end_date <= Date.parse($scope.schedule.end_date)
      $scope.newAvailabilities.push {
        start_datetime: new Date(this_start_date),
        end_datetime: new Date(this_end_date),
        schedule_id: $scope.newAvailability.schedule_id
      }
      this_start_date.setDate(this_start_date.getDate()+7)
      this_end_date.setDate(this_end_date.getDate()+7)

    # Save the calculated availabilities
    $scope.error = null
    availabilities = $scope.employee.employee_availabilities || []
    $scope.employee.employee_availabilities_attributes = availabilities.concat($scope.newAvailabilities)
    Employees.update $scope.employee,
      (data) ->
        # Success
        $scope.init()
        # Reset $scope.newAvailability
        $scope.newAvailability = {
          schedule_id: $scope.newAvailability.schedule_id
        }
    , (data) ->
        # Failure
        $scope.error = 'Could not save availabilities, please try again'
        # Display specific errors
        _.each(data.data , (e,i) ->
            $scope.error = $scope.error + "<li>#{i}: #{e}</li>"
          )

  $scope.confirmDeleteAvailability = (availability) ->
    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "Delete this availability?"
        body: ->
          "#{availability.start_datetime} - #{availability.end_datetime}"
        okButton: ->
          "Delete"
        showCancel: ->
          true

    modalInstance.result.then () ->
      $scope.deleteShift(shift)

  $scope.deleteAvailability = (availability) ->
    Shifts.delete {id: shift.id},
      (data) ->
        # Success
        index = $scope.shifts.indexOf(shift)
        $scope.shifts.splice(index,1)
        $scope.init()
    , (data) ->
        # Error
        $scope.error = "Error deleting shift '#{shift.start_datetime} - #{shift.end_datetime}'"

  $scope.setScheduleName = ->
    $scope.schedule = _.findWhere($scope.schedules, { id: $scope.newAvailability.schedule_id })

  $scope.setSchedule = (schedule) ->
    $scope.newAvailability.schedule_id = schedule.id
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
    select: $scope.createAvailability
    eventAfterRender: (event, element) -> # Here we customize the content and the color of the cell
      element.find('.fc-event-inner').css('display','none') if event.isBackground
    eventClick: (calEvent, jsEvent, view) ->
      $scope.confirmDeleteShift(calEvent)
