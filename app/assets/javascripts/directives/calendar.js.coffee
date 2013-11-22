StaffScheduler.directive "calendar", @calendar = () ->
  link: (scope, element, attrs) ->
    element.fullCalendar
      weekends: false
      contentHeight: 600
      defaultView: "agendaWeek"
      header:
        left: "prev,next"
        center: "title"
        right: "today agendaWeek,agendaDay"
        ignoreTimezone: false

    element.on "$destroy", ->
      element.fullCalendar "destroy"
