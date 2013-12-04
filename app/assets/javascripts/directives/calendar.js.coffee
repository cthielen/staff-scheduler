StaffScheduler.directive "calendar", @calendar = () ->
  link: (scope, element, attrs) ->
    scope.modalVisible = false

    createShift = (startDate, endDate, allDay) ->
      scope.modalTemplate = "assets/partials/newShift.html"
      scope.modalVisible = true
      scope.$apply() unless scope.$$phase
      
    element.fullCalendar
      weekends: false
      contentHeight: 600
      defaultView: "agendaWeek"
      selectable: true
      header:
        left: "prev,next"
        center: "title"
        right: "today agendaWeek,agendaDay"
        ignoreTimezone: false
      select: (startDate, endDate, allDay, jsEvent, view) =>
        createShift(startDate, endDate, allDay)

    element.on "$destroy", ->
      element.fullCalendar "destroy"
