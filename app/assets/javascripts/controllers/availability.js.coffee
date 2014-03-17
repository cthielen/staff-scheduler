StaffScheduler.controller "AvailabilityCtrl", @AvailabilityCtrl = ($scope, $filter, $modal, $location, $timeout, Shifts, Schedules, Skills, Locations, Employees, Availabilities, CurrentEmployee, EmployeeSchedules) ->
  $scope.modalTemplate = null
  $scope.error = null
  $scope.modalVisible = false
  CurrentEmployee.query (data) ->
    if data.id
      Employees.get {id: data.id},
        (data) ->
          # Success
          $scope.employee = data
      , (data) ->
          # Error
          $scope.error = 'Could not query current user'
  
  $(".navbar-nav li").removeClass "active"
  $("li#availability").addClass "active"

  $scope.newAvailability = {}
  $scope.newAvailabilities = []
  $scope.availabilities = []
  $scope.employeeSchedules = []
  $scope.shifts = []
  $scope.calSources = [{
      color: "#7AB"
      events: $scope.availabilities
    },{
      color: "#999"
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

  $scope.fetchEmployeeSchedules = ->    
    unless $scope.newAvailability.schedule_id is undefined
      console.log 'Fetching employee schedules...'
      EmployeeSchedules.query {
        schedule: $scope.schedule.id
        }, (result) ->
          # Success        
          $scope.employeeSchedules.length = 0 # Preferred way of emptying a JS array
          angular.forEach result, (item) ->
            $scope.employeeSchedules.push item if item.id
          
          $scope.$apply
          $scope.setEmployeeSchedule()   
                
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
      $scope.fetchEmployeeSchedules()
      
      # Change calendar date to the beginning of the schedule
      schedule = _.findWhere($scope.schedules, { id: $scope.newAvailability.schedule_id })
      scheduleStart = new Date(Date.parse(schedule.start_date))
  
  $scope.createAvailability = (startDate, endDate) ->
    $scope.alertClass = "alert-warning"
    $scope.alertText = "Saving Availability..."

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
        $scope.alertClass = "alert-success"
        $scope.alertText = "Saved Successfully!"

        $timeout.cancel(displayStatus)
        displayStatus = $timeout (->
          $scope.alertClass = null
          $scope.alertText = null
        ), 3000

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
      $scope.deleteAvailability(availability)

  $scope.deleteAvailability = (availability) ->
    Availabilities.delete {id: availability.id},
      (data) ->
        # Success
        index = $scope.availabilities.indexOf(availability)
        $scope.availabilities.splice(index,1)
        $scope.init()
    , (data) ->
        # Error
        $scope.error = "Error deleting availability '#{availability.start_datetime} - #{availability.end_datetime}'"

  $scope.setScheduleName = ->
    $scope.schedule = _.findWhere($scope.schedules, { id: $scope.newAvailability.schedule_id })

  $scope.setSchedule = (schedule) ->
    $scope.newAvailability.schedule_id = schedule.id
    $scope.init()

  $scope.setEmployeeSchedule = ->
    $scope.employeeSchedule = _.findWhere($scope.employeeSchedules, { schedule_id: $scope.schedule.id})
  $scope.clearError = ->
    $scope.error = null

  $scope.submitEmployeeSchedules = () ->
    $scope.employeeSchedule.availability_submitted = true
    EmployeeSchedules.update $scope.employeeSchedule,
      (data) ->
        # Success
    , (data) ->
        # Error
        
        
    
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
      $scope.confirmDeleteAvailability(calEvent)
