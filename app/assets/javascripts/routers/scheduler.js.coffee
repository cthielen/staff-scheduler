schedulerRouter = ($routeProvider) ->
  $routeProvider
    .when "/",
      template: "{{error}} Loading..."
      controller: "ScheduleRedirectCtrl"
    .when "/employees",
      templateUrl: "/assets/partials/employees.html"
      controller: "EmployeesCtrl"
    .when "/schedules/new",
      templateUrl: "/assets/partials/editSchedule.html"
      controller: "EditScheduleCtrl"
    .when "/schedules/edit/:id",
      templateUrl: "/assets/partials/editSchedule.html"
      controller: "EditScheduleCtrl"
    .when "/schedules/:id",
      templateUrl: "/assets/partials/planner.html"
      controller: "PlannerCtrl"
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
