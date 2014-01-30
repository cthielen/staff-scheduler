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
