StaffScheduler.directive "modal", @modal = () ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.$watch "modalVisible ", (newVal, oldVal) ->
      if newVal
        element.modal()
      else
        element.modal "hide"

    scope.okFn = ->
      scope.dismissModal()

    scope.cancelFn = ->
      scope.dismissModal()
