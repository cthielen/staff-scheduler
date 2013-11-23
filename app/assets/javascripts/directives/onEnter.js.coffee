StaffScheduler.directive "onEnter", @onEnter = () ->
  (scope, element, attrs) ->
    element.bind "keydown keypress", (event) ->
      if event.which is 13
        scope.$apply ->
          scope.$eval attrs.onEnter

        event.preventDefault()
