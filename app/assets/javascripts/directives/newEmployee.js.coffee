StaffScheduler.directive "newEmployee", @newEmployee = (Employees) ->
  templateUrl: '/assets/partials/newEmployee.html'
  link: (scope, element, attrs) ->
    scope.initFields = ->
      # Reset fields
      angular.forEach scope.newEmp, (value,key) =>
        scope.newEmp[key] = ''
      scope.newEmp['max_hours'] = 10
      $("input[name='new-name']").focus()

    scope.submit = ->
      # Submit only if all fields are filled
      unless (scope.newEmp['name'] is '' or scope.newEmp['email'] is '' or scope.newEmp['max_hours'] is '')
        Employees.save scope.newEmp, (data) ->
          scope.employees.push(data);
          scope.initFields()
    
    scope.initFields()
