StaffScheduler.controller "PlannerCtrl", @PlannerCtrl = ($scope, Schedules, Skills, Locations, LocationSkillCombinations) ->

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

  ## Fetching Data
  # Fetch Location/Skill combinations
  LocationSkillCombinations.then (combinations) ->
    $scope.locationSkillCombinations = combinations

  # Fetch Schedules
  $scope.schedules = Schedules.query (response) ->
    if response.length
      $scope.selections.schedule = response[0]
    else
      $scope.redirectTo('schedule','/schedules')

  # TODO: See if you can move these functions to a factory
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
    eventAfterRender: (event, element) -> # Here we customize the content and the color of the cell
      element.find('.fc-event-inner').css('display','none') if event.isBackground
