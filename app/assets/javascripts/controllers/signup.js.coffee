Welcome.controller "SignupCtrl", @SignupCtrl = ($scope, $http) ->
  $scope.requestSent = null
  $scope.SendRequest = ->
    $http.post(
      "/signup",
      name: $scope.name
      email: $scope.email
      reason: $scope.reason
    )
    .success () ->
      $scope.name = $scope.email = $scope.reason = ""
      $scope.requestSent = "success"
    .error ->
      $scope.requestSent = "error"
