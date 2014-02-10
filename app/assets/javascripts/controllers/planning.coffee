StaffScheduler.controller "PlanningCtrl", @PlanningCtrl = ($scope, $filter, $modal) ->
  $scope.error = null
  $(".navbar-nav li").removeClass "active"
  $("li#planning").addClass "active"

  $scope.shiftAssignmentSources = []

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
