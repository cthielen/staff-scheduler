StaffScheduler.directive "newEmployee", @newEmployee = (Employees) ->
  templateUrl: '/assets/partials/newEmployee.html'
  link: (scope, element, attrs) ->
    scope.submit = ->
      # Submit only if the 3 fields are filled
      unless (scope.newEmp['name'] is '' or scope.newEmp['email'] is '' or scope.newEmp['max_hours'] is '')
        Employees.save scope.newEmp, (data) ->
          scope.employees.push(data);
        
    