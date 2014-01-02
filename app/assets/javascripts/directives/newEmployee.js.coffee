StaffScheduler.directive "newEmployee", @newEmployee = (Employees, EmpLookup) ->
  templateUrl: '/assets/partials/newEmployee.html'
  link: (scope, element, attrs) ->
    scope.names = []
    
    scope.$watch "newEmp.name", (value) ->
      EmpLookup.query
        q: value
      , (response) ->
        scope.names = []
        angular.forEach response, (item) ->
          scope.names.push item.name  if item.id
      
    
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
