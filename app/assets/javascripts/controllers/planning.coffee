StaffScheduler.controller "PlanningCtrl", @PlanningCtrl = ($scope, $filter, $modal, Schedules, Skills, Locations, Availabilities, Assignments) ->
  $scope.error = null
  $(".navbar-nav li").removeClass "active"
  $("li#planning").addClass "active"

  $scope.newAssignment = {}
  $scope.currentLocationSkill = 0
  $scope.locationSkillCombinations = []
  $scope.availabilities = []
  $scope.shiftAssignments = []
  $scope.shiftAssignmentSources = [
    {
      color: "#7AB"
      textColor: "yellow"
      events: $scope.shiftAssignments
    },
    {
      color: "#999"
      events: $scope.availabilities
    }
  ]

  $scope.schedules = Schedules.query (response) ->
    if response.length
      $scope.newAssignment.schedule_id = response[0].id
      $scope.$apply
      $scope.init()
    else
      $scope.redirectTo('schedule','/schedules')

  $scope.init = ->
    if $scope.newAssignment.schedule_id and $scope.locationSkillCombinations.length > 0
      $scope.fetchAvailabilities()
      $scope.fetchShiftAssignments()
      $scope.currentSelectionsNames()

  $scope.currentSelectionsNames = ->
    skill = $scope.locationSkillCombinations[$scope.currentLocationSkill].skill.title
    location = $scope.locationSkillCombinations[$scope.currentLocationSkill].location.name
    schedule = _.findWhere($scope.schedules, { id: $scope.newAssignment.schedule_id }).name
    $scope.selectionsNames = {skill: skill, location: location, schedule: schedule}

  $scope.fetchAvailabilities = ->
    console.log 'Fetching availabilities...'
    if $scope.locationSkillCombinations.length
      Availabilities.query {
        schedule: $scope.newAssignment.schedule_id,
        location: $scope.locationSkillCombinations[$scope.currentLocationSkill].location.id,
        skill: $scope.locationSkillCombinations[$scope.currentLocationSkill].skill.id
      }, (result) ->
        # Success
        $scope.availabilities.length = 0 # Preferred way of emptying a JS array
        angular.forEach result, (item) ->
          item.isBackground = true
          $scope.availabilities.push item if item.id

        $scope.$apply
        $scope.assignmentCalendar.fullCalendar 'refetchEvents'

  $scope.fetchShiftAssignments = ->
    console.log 'Fetching shift assignments...'
    if $scope.locationSkillCombinations.length
      Assignments.query {
        schedule: $scope.newAssignment.schedule_id,
        location: $scope.locationSkillCombinations[$scope.currentLocationSkill].location.id,
        skill: $scope.locationSkillCombinations[$scope.currentLocationSkill].skill.id
      }, (result) ->
        # Success
        $scope.shiftAssignments.length = 0 # Preferred way of emptying a JS array
        angular.forEach result, (item) ->
          $scope.shiftAssignments.push item if item.id

        $scope.$apply
        $scope.assignmentCalendar.fullCalendar 'refetchEvents'

  $scope.switchLocationSkill = (clicked) ->
    $scope.currentLocationSkill = clicked
    $scope.init()

  $scope.setSchedule = (schedule) ->
    $scope.newAssignment.schedule_id = schedule.id
    $scope.init()

  $scope.getLocationSkillCombinations = ->
    Skills.query {},
      (skills) ->
        # Success
        Locations.query {},
          (locations) ->
            # Success
            $scope.locationSkillCombinations.length = 0
            angular.forEach locations, (location) ->
              if location.id
                angular.forEach skills, (skill) ->
                  $scope.locationSkillCombinations.push {skill: skill, location: location} if skill.id

            $scope.init()
            if $scope.locationSkillCombinations.length > 1
              $scope.calendarClass = 'col-md-6'
            else
              $scope.calendarClass = 'col-md-12'
          (data) ->
            # Error
      (data) ->
        # Error

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

  $scope.getLocationSkillCombinations()
  # config calendar 
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
    eventAfterRender: (event, element) -> # Here we customize the content and the color of the cell
      element.find('.fc-event-inner').css('display','none') if event.isBackground
