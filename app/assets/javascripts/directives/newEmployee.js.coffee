StaffScheduler.directive "newEmployee", @newEmployee = () ->
  templateUrl: '/assets/partials/newEmployee.html'
  link: (scope, element, attrs) ->
    scope.submit = ->
      console.log "submitted"
    