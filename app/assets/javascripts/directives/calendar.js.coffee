StaffScheduler.directive "calendar", @calendar = () ->
  restrict: 'E'
  templateUrl: '/assets/partials/calendar.html'
  scope:
    create: '&onSelect'
    events: '='
  link: (scope, element, attrs) ->
    scope.viewDate = new Date()
    scope.viewWeek = []
    scope.getWeek = (d) ->
      scope.viewWeek = []
      d = new Date(d)
      day = d.getDay()
      diff = d.getDate() - day + ((if day is 0 then -6 else 1)) # Mon = 1
      scope.viewWeek.push new Date(d.setDate(i)) for i in [diff .. diff+4]
      scope.viewWeek

    scope.getWeek(scope.viewDate)
    scope.$watch "viewDate", (value, old) ->
      scope.getWeek(value)
    , true

    # Set the hours array
    scope.$watch "viewDate", (value, old) ->
      minHr = 7
      maxHr = 18
      scope.step = 0.5
      scope.hours = []
      while minHr < maxHr
        hour = new Date(scope.viewDate)
        diff = hour.getDate() - hour.getDay() + ((if hour.getDay() is 0 then -6 else 1)) # Mon = 1
        hour =  new Date(hour.setDate(diff))
        hour.setSeconds(0)
        hour.setHours(minHr)
        hour.setMinutes(minHr%1*60)
        scope.hours.push hour
        minHr+=scope.step
    , true
    
    scope.previousWeek = ->
      scope.viewDate.setDate(scope.viewDate.getDate() - 7)

    scope.nextWeek = ->
      scope.viewDate.setDate(scope.viewDate.getDate() + 7)

    currentCol = undefined
    element.selectable
      filter: "td"
      stop: (event, ui) ->
        currentCol = undefined
        selection = _.map( $('#selectable td.ui-selected'), (i) ->
          [$(i).closest('tr').attr('data-row'),$(i).closest('td').attr('data-col')] )
        if selection.length > 0
          startDateSelected = new Date(selection[0][0])
          startDateSelected.setDate(startDateSelected.getDate() + parseInt(selection[0][1]))
          endDateSelected = new Date(selection[selection.length-1][0])
          endDateSelected.setDate(endDateSelected.getDate() + parseInt(selection[0][1]))
          scope.create({startDate: startDateSelected, endDate: endDateSelected})

      selecting: (event, ui) ->
        # Exclude columns with no data-col attribute
        $(ui.selecting).removeClass('ui-selecting') if $(ui.selecting).attr("data-col") is undefined
        # Prevent highlighting the cell if it is in a different column
        currentCol = $(ui.selecting).attr("data-col") if currentCol is undefined
        $(ui.selecting).removeClass('ui-selecting') unless $(ui.selecting).attr("data-col") is currentCol

    # TODO: Render the events on calendar
    scope.$watch "events", (newVal, oldVal) ->
      console.log newVal.length
    , true
