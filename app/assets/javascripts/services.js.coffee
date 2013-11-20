angular.module("schedulerServices", ["ngResource"])
  .factory "Employees", ($resource) ->
    $resource "/employees.json"
