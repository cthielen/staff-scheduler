var Welcome = angular.module('welcome', ['ngRoute']);

Welcome.config(welcomeRouter);
Welcome.config(includeCSRF);


function welcomeRouter ($routeProvider) {
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