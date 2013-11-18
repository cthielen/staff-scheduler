function scheduleCtrl ($scope) {

  $("#calendar").fullCalendar({
    weekends: false,
    contentHeight: 600,
    defaultView: 'agendaWeek',
    header: {
      left: "prev,next",
      center: "title",
      right: "today agendaWeek,agendaDay",
      ignoreTimezone: false
    }
  });
}

