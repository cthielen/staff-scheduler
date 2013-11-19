Welcome.controller "SignupCtrl", @SignupCtrl = ($scope, $http) ->
  $scope.SendRequest = ->
    $http.post("/signup",
      name: $scope.name
      email: $scope.email
      reason: $scope.reason
    ).success(->
      $scope.name = $scope.email = $scope.reason = ""
      $("#success").removeClass "hidden"
    ).error ->
      $("#error").removeClass "hidden"

