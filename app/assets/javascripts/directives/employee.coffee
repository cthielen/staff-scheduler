StaffScheduler.directive "employee", @employee = (Employees) ->
  templateUrl: '/assets/partials/employee.html'
  link: (scope, element, attrs) ->
    scope.showDelete = false
    scope.editing = false

    scope.showOptions = ->
      scope.showDelete = true

    scope.hideOptions = ->
      scope.showDelete = false

    scope.editEmployee = ->
      scope.editing = true

    scope.applyChanges = (employee) ->
      scope.editing = false
      Employees.update employee

    scope.deleteEmployee = (employee) ->
      index = scope.employees.indexOf(employee)
      employee.is_disabled = true
      Employees.update employee, (data) ->
        scope.employees.splice(index,1)
