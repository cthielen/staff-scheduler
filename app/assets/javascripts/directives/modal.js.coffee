StaffScheduler.directive "modal", @modal = ($compile) ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    # This will make sure the content of the template iscomplied in order to use the ng components
    $compile(element.contents())(scope)
    scope.title = attrs.title

    scope.$watch "modalVisible ", (newVal, oldVal) ->
      if newVal
        element.modal()
      else
        element.modal "hide"
