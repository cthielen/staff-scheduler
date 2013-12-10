StaffScheduler.directive "calendar", @calendar = () ->
  link: (scope, element, attrs) ->
    scope.$watch "shifts", (newVal, oldVal) ->
      element.fullCalendar "refetchEvents"

    createShift = (startDate, endDate, allDay) ->
      scope.showModal("/assets/partials/newShift.html", startDate, endDate, allDay)
      
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
        createShift(startDate, endDate, allDay)

    element.on "$destroy", ->
      element.fullCalendar "destroy"
