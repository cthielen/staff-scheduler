schedulerRouter = ($routeProvider) ->
  $routeProvider
    .when "/",
      templateUrl: "/assets/partials/shifts.html"
      controller: "ShiftsCtrl"
    .when "/availability",
      templateUrl: "/assets/partials/availability.html"
      controller: "AvailabilityCtrl"
    .when "/planning",
      templateUrl: "/assets/partials/planning.html"
      controller: "PlanningCtrl"
    .when "/employees",
      templateUrl: "/assets/partials/employees.html"
      controller: "EmployeesCtrl"
    .when "/schedules",
      templateUrl: "/assets/partials/schedules.html"
      controller: "SchedulesCtrl"

includeCSRF = ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")

window.StaffScheduler = angular.module("scheduler", ["ngRoute", "ngSanitize","schedulerServices","ui.bootstrap","ui.calendar"])
StaffScheduler.config schedulerRouter
StaffScheduler.config includeCSRF