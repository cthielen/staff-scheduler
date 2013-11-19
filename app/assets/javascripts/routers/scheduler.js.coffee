schedulerRouter = ($routeProvider) ->
  $routeProvider.when("/",
    templateUrl: "/assets/partials/schedule.html"
    controller: "ScheduleCtrl"
  ).when "/employees",
    templateUrl: "/assets/partials/employees.html"
    controller: "EmployeesCtrl"

includeCSRF = ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")

window.StaffScheduler = angular.module("scheduler", ["ngRoute"])
StaffScheduler.config schedulerRouter
StaffScheduler.config includeCSRF