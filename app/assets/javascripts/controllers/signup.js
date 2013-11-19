function SignupCtrl ($scope, $http) {
  $scope.SendRequest = function() {
    console.log('sending');
    $http.post("/signup", { name: $scope.name, email: $scope.email, reason: $scope.reason});
  }
}
