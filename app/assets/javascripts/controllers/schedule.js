function ScheduleCtrl ($scope) {
  
  $(".navbar-nav li").removeClass('active');
  $("li#schedule").addClass('active');
  
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

