StaffScheduler.controller "EmployeesCtrl", @EmployeesCtrl = ($scope, $routeParams, $modal, $http, Employees, CurrentEmployee, Skills, Locations) ->
  $(".navbar-nav li").removeClass "active"
  $("li#employees").addClass "active"
  $scope.error = null
  $scope.selectedEmployee = {}
  $scope.submitText = 'Create Employee'

  Employees.query {}, (result) ->
    $scope.employees = result

  CurrentEmployee.query (result) ->
    $scope.currentEmployee = result

  Locations.query {}, (result) ->
    # Success
    $scope.locations = []
    angular.forEach result, (item) ->
      $scope.locations.push item if item.id

  Skills.query {}, (result) ->
    # Success
    $scope.skills = []
    angular.forEach result, (item) ->
      $scope.skills.push item if item.id

  $scope.selectEmployee = (employee) ->
    $scope.selectedEmployee = employee
    $scope.submitText = 'Update Employee'
    angular.forEach $scope.locations, (item) ->
      if _.find(employee.locations, (l) -> l.id == item.id)
        item.assigned = true
      else
        item.assigned = false
    angular.forEach $scope.skills, (item) ->
      if _.find(employee.skills, (s) -> s.id == item.id)
        item.assigned = true
      else
        item.assigned = false

  $scope.unselectEmployee = () ->
    $scope.selectedEmployee = {}
    $scope.submitText = 'Create Employee'
    angular.forEach $scope.locations, (item) ->
      item.assigned = false
    angular.forEach $scope.skills, (item) ->
      item.assigned = false

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
      $scope.unselectEmployee()
      $scope.employees.splice(index,1)


  $scope.queryNames = (query) ->
    $http.get("/employee-lookup.json",
      params:
        q: query
    ).then (res) ->
      entities= []
      angular.forEach res.data, (i) ->
        entities.push i
      entities

  $scope.getEmail = (entity) ->
    $scope.selectedEmployee.name = entity.name
    $http.get("/rm-employee.json",
      params:
        q: entity.loginid
    ).then (res) ->
      $scope.selectedEmployee.email = res.data.email

  $scope.save = ->
    $scope.error = null
    $scope.submitText = 'Saving...'

    $scope.selectedEmployee.location_assignments_attributes = _.map(
        _.filter($scope.locations, (l) ->l.assigned), (loc) -> {location_id: loc.id}
      )
    $scope.selectedEmployee.skill_assignments_attributes = _.map(
        _.filter($scope.skills, (s) -> s.assigned), (skl) -> {skill_id: skl.id}
      )

    if $scope.selectedEmployee.id
      Employees.update $scope.selectedEmployee,
        (data) ->
          # Success
          $scope.unselectEmployee()
        (data) ->
          # Failure
          $scope.error = 'Could not save employee, please try saving again'
          $scope.submitText = 'Try Again'
    else
      Employees.save $scope.selectedEmployee,
        (data) ->
          # Success
          $scope.unselectEmployee()
          $scope.employees.push data
        (data) ->
          # Failure
          $scope.error = 'Could not save employee, please try saving again'
          $scope.submitText = 'Try Again'

  # Skills
  $scope.newSkill = {}

  $scope.createSkill = () ->
    Skills.save $scope.newSkill,
      (data) ->
        # Success
        $scope.skills.push data
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

  $scope.confirmDeleteSkill = (skill) ->
    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "Delete this skill?"
        body: ->
          "#{skill.title}"
        okButton: ->
          "Delete"
        showCancel: ->
          true

    modalInstance.result.then () ->
      skill.is_disabled = true
      Skills.update skill,
        (data) ->
          # Success
          $scope.deleteSkill(skill)
        (data) ->
          # Failure
          $scope.error = 'Could not delete skill, please try deleting again'

  $scope.deleteSkill = (skill) ->
    index = $scope.skills.indexOf(skill)
    $scope.skills.splice(index,1)

  # Locations
  $scope.newLocation = {}

  $scope.createLocation = () ->
    Locations.save $scope.newLocation,
      (data) ->
        # Success
        $scope.locations.push data
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

  $scope.confirmDeleteLocation = (location) ->
    modalInstance = $modal.open
      templateUrl: '/assets/partials/confirm.html'
      controller: ConfirmCtrl
      resolve:
        title: ->
          "Delete this location?"
        body: ->
          "#{location.name}"
        okButton: ->
          "Delete"
        showCancel: ->
          true

    modalInstance.result.then () ->
      location.is_disabled = true
      Locations.update location,
        (data) ->
          # Success
          $scope.deleteLocation(location)
        (data) ->
          # Failure
          $scope.error = 'Could not delete location, please try deleting again'

  $scope.deleteLocation = (location) ->
    index = $scope.locations.indexOf(location)
    $scope.locations.splice(index,1)
