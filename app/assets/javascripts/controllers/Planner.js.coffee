StaffScheduler.controller "PlannerCtrl", @PlannerCtrl = ($scope, Skills, Locations, LocationSkillCombinations) ->

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

  LocationSkillCombinations.then (combinations) ->
    $scope.locationSkillCombinations = combinations

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
