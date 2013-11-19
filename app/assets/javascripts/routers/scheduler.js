var StaffScheduler = angular.module('scheduler', ['ngRoute']);

StaffScheduler.config(schedulerRouter);
StaffScheduler.config(includeCSRF);


function schedulerRouter ($routeProvider) {
	$routeProvider
	.when('/', {
    templateUrl: '/assets/partials/schedule.html',
    controller: 'ScheduleCtrl'
  })
  .when('/employees', {
      templateUrl: '/assets/partials/employees.html',
      controller: 'EmployeesCtrl'
    });
}

function includeCSRF ($httpProvider) {
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}