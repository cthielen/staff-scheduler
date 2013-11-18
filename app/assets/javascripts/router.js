angular.module('scheduler', ['ngRoute'])
	.config(schedulerRouter);

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