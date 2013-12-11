StaffScheduler.directive "calendar", @calendar = ($modal) ->
  link: (scope, element, attrs) ->
    scope.$watch "shifts", (newVal, oldVal) ->
      element.fullCalendar "refetchEvents"
    ,true

    element.fullCalendar
      weekends: false
      contentHeight: 600
      defaultView: "agendaWeek"
      selectable: true
      minTime: 7
      maxTime: 19
      header:
        left: "prev,next"
        center: "title"
        right: "today agendaWeek,agendaDay"
        ignoreTimezone: false
      events: "/shifts.json"
      select: (startDate, endDate, allDay, jsEvent, view) =>
        scope.newShift.start_datetime = startDate
        scope.newShift.end_datetime = endDate

        modalInstance = $modal.open
          templateUrl: "/assets/partials/newShift.html"
          controller: NewShiftCtrl
          resolve:
            shifts: ->
              scope.shifts
            newShift: ->
              scope.newShift

        modalInstance.result.then (shifts) ->
          scope.shifts = shifts

    element.on "$destroy", ->
      element.fullCalendar "destroy"
