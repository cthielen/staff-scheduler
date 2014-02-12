StaffScheduler.directive "stopEvent", @stopEvent = () ->
  (scope, element, attrs) ->
    element.bind attrs.stopEvent, (e) ->
      e.stopPropagation()
