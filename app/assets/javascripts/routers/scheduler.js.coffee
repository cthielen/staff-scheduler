schedulerRouter = ($routeProvider) ->
  $routeProvider
    .when "/",
      templateUrl: "/assets/partials/shifts.html"
      controller: "ShiftsCtrl"
    .when "/employees",
      templateUrl: "/assets/partials/employees.html"
      controller: "EmployeesCtrl"
    .when "/schedules",
      templateUrl: "/assets/partials/schedules.html"
      controller: "SchedulesCtrl"

includeCSRF = ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")

window.StaffScheduler = angular.module("scheduler", ["ngRoute","schedulerServices"])
StaffScheduler.config schedulerRouter
StaffScheduler.config includeCSRF