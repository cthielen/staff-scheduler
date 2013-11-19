function SignupCtrl ($scope, $http) {

  $scope.SendRequest = function() {
    $http.post("/signup", { name: $scope.name, email: $scope.email, reason: $scope.reason})
    .success( function () {
      $scope.name = $scope.email = $scope.reason = '';
      $('#success').removeClass('hidden');
    })
    .error( function () {
      $('#error').removeClass('hidden');
    });
  }
}
