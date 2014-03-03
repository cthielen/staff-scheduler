welcomeRouter = ($routeProvider) ->
  $routeProvider.when("/",
    templateUrl: "/assets/partials/welcome.html"
  ).when "/signup",
    templateUrl: "/assets/partials/signup.html"
    controller: "SignupCtrl"

includeCSRF = ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")

window.Welcome = angular.module("welcome", ["ngRoute", "ngSanitize"])
Welcome.config welcomeRouter
Welcome.config includeCSRF