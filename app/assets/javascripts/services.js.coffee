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
  .factory "EmpLookup", ($resource) ->
    $resource "/employee-lookup.json?q=:q",
      q: "@q"
      
  .factory "CurrentEmployee", () ->
    currentEmployee = { id: window.current_employee_id }
