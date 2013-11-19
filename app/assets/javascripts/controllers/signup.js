function SignupCtrl ($scope, $http) {
  $http.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');

  $scope.SendRequest = function() {
    console.log('sending');
    $http.post("/signup", { name: $scope.name, email: $scope.email, reason: $scope.reason});
  }
}
