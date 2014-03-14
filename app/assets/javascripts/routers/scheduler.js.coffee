schedulerRouter = ($routeProvider) ->
  $routeProvider
    .when "/",
      templateUrl: "/assets/partials/planner.html"
      controller: "PlannerCtrl"
    .when "/shifts",
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
    .when "/about",
      template: '&nbsp'
      resolve:
        data: ($modal, LastUpdated) ->
          modalInstance = $modal.open
            templateUrl: '/assets/partials/confirm.html'
            controller: ConfirmCtrl
            resolve:
              title: ->
                "About"
              body: ->
                "<h4>Staff Scheduler</h4>
                Last updated: #{LastUpdated.date}"
              okButton: ->
                "OK"
              showCancel: ->
                false
          modalInstance.result.then () ->
            history.back()
    .otherwise redirectTo: "/"

includeCSRF = ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")

window.StaffScheduler = angular.module("scheduler", ["ngRoute", "ngSanitize","schedulerServices","ui.bootstrap","ui.calendar"])
StaffScheduler.config schedulerRouter
StaffScheduler.config includeCSRF