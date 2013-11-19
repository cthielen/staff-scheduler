var StaffScheduler = angular.module('scheduler', ['ngRoute']);

StaffScheduler.config(schedulerRouter);
StaffScheduler.config(includeCSRF);


function schedulerRouter ($routeProvider) {
	$routeProvider
	.when('/', {
    templateUrl: '/assets/partials/welcome.html',
  })
  .when('/signup', {
      templateUrl: '/assets/partials/signup.html',
      controller: 'SignupCtrl'
    });
}

function includeCSRF ($httpProvider) {
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}