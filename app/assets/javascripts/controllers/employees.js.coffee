StaffScheduler.controller "EmployeesCtrl", @EmployeesCtrl = ($scope, $routeParams, $modal, Employees, EmpLookup, Skills, Locations) ->
  $(".navbar-nav li").removeClass "active"
  $("li#employees").addClass "active"
  $scope.error = null

  $scope.employees = Employees.query()
  
  $scope.editEmployee = (employee) ->
    modalInstance = $modal.open
      templateUrl: "/assets/partials/editEmployee.html"
      controller: EditEmployeeCtrl
      resolve:
        employee: ->
          employee

    modalInstance.result.then (employee) ->
      $scope.applyChanges employee

  $scope.applyChanges = (employee) ->
    Employees.update employee

  $scope.confirmDeleteEmployee = (employee) ->
    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "Delete this employee?"
        body: ->
          "#{employee.name}"
        okButton: ->
          "Delete"
        showCancel: ->
          true

    modalInstance.result.then () ->
      $scope.deleteEmployee(employee)

  $scope.deleteEmployee = (employee) ->
    index = $scope.employees.indexOf(employee)
    employee.is_disabled = true
    Employees.update employee, (data) ->
      $scope.employees.splice(index,1)


  # New employee row
  $scope.names = []
  $scope.rowClass = ''
  $scope.newEmp = {name: ''}
  
  $scope.$watch "newEmp.name", (value) ->
    if value.length > 1
      EmpLookup.query
        q: value
      , (response) ->
        $scope.names = []
        angular.forEach response, (item) ->
          $scope.names.push item.name  if item.id
    
  
  $scope.initFields = ->
    # Reset fields
    angular.forEach $scope.newEmp, (value,key) =>
      $scope.newEmp[key] = ''
    $scope.newEmp['max_hours'] = 10
    $("input[name='new-name']").focus()

  $scope.submit = ->
    # Submit only if all fields are filled
    unless ($scope.newEmp['name'] is '' or $scope.newEmp['email'] is '' or $scope.newEmp['max_hours'] is '')
      Employees.save $scope.newEmp,
        (data) ->
          # Success
          $scope.employees.push(data);
          $scope.initFields()
          $scope.rowClass = ''
      , (data) ->
          # Error
          $scope.rowClass = 'error'
  
  $scope.initFields()

  # Skills
  $scope.newSkill = {}

  $scope.fetchSkills = () ->
    $scope.skills = Skills.query()

  $scope.createSkill = () ->
    Skills.save $scope.newSkill,
      (data) ->
        # Success
        $scope.skills = Skills.query()
        $scope.newSkill = {}
        $scope.error= null
    , (data) ->
        # Error
        $scope.error= 'Error creating new skill'

  $scope.editSkill = (skill) ->
    modalInstance = $modal.open
      templateUrl: "/assets/partials/editSkill.html"
      controller: EditSkillCtrl
      resolve:
        skill: ->
          skill

    modalInstance.result.then (skill) ->
      $scope.deleteSkill skill if skill is 'deleted'

  $scope.deleteSkill = (skill) ->
    index = $scope.skills.indexOf(skill)
    $scope.skills.splice(index,1)

  # Locations
  $scope.newLocation = {}

  $scope.fetchLocations = () ->
    $scope.locations = Locations.query()

  $scope.createLocation = () ->
    Locations.save $scope.newLocation,
      (data) ->
        # Success
        $scope.locations = Locations.query()
        $scope.newLocation = {}
        $scope.error= null
    , (data) ->
        # Error
        $scope.error= 'Error creating new location'

  $scope.editLocation = (location) ->
    modalInstance = $modal.open
      templateUrl: "/assets/partials/editLocation.html"
      controller: EditLocationCtrl
      resolve:
        location: ->
          location

    modalInstance.result.then (location) ->
      $scope.deleteLocation location if location is 'deleted'

  $scope.deleteLocation = (location) ->
    index = $scope.locations.indexOf(location)
    $scope.locations.splice(index,1)
