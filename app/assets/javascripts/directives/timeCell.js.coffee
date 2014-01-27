StaffScheduler.directive "timeCell", @timeCell = () ->
  scope:
    day: '&dataDay'
    hour: '&dataHour'
    events: '='
  link: (scope, element, attrs) ->
    cellDate= new Date(attrs.hour)
    cellDate.setDate(cellDate.getDate() + parseInt(attrs.day))
    scope.$watch "events", (events) ->
      cellEvents = _.filter(events, (e) ->
          element.append('<div style="position: absolute; background-color: rgba(102,153,153,0.5); left: 0px; top: 0px; width: 90%; height: 20px; color: white; margin: 0 5%; z-index:3; border: 1px black solid;"></div>') if new Date(e.start_datetime).getTime() is cellDate.getTime()
        )
    , true
