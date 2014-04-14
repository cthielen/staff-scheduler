angular.module("schedulerServices", ["ngResource"])
  .factory "Employees", ($resource) ->
    $resource "/employees/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"
  .factory "Shifts", ($resource) ->
    $resource "/shifts/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"
  .factory "Availabilities", ($resource) ->
    $resource "/employee_availabilities/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"
  .factory "Assignments", ($resource) ->
    $resource "/shift_assignments/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"
  .factory "Schedules", ($resource) ->
    $resource "/schedules/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"
      calculate:
        method: "PUT"
        url: '/schedules/:id.json?calculate=true'

  .factory "Skills", ($resource) ->
    $resource "/skills/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"
  .factory "Locations", ($resource) ->
    $resource "/locations/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"
  .factory "Locations", ($resource) ->
    $resource "/locations/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"    
  .factory "EmployeeSchedules", ($resource) ->
    $resource "/employee_schedules/:id.json",
      id: "@id"
    ,
      update:
        method: "PUT"     
  .factory "LocationSkillCombinations", ($http, $q) ->
    # Calculate the Location/Skill combinations
    deferred = $q.defer()
    locationSkillCombinations = []
    $http.get("/skills.json").then (skills) ->
      $http.get("/locations.json").then (locations) ->
        angular.forEach locations.data, (location) ->
          if location.id
            angular.forEach skills.data, (skill) ->
              locationSkillCombinations.push {skill: skill, location: location} if skill.id
        deferred.resolve(locationSkillCombinations)
    deferred.promise

  .factory "LastUpdated", () ->
    lastUpdated= { date: window.last_updated }

  .factory "CurrentEmployee", ($resource) ->
    $resource "/current-employee",
      id: "@id"
    ,
      query:
        method: 'GET'
        isArray: false
