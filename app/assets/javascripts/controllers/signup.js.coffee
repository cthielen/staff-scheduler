Welcome.controller "SignupCtrl", @SignupCtrl = ($scope, $http) ->
  $scope.sendStatus = null
  $scope.alertClass = ''
  
  $scope.SendRequest = ->
    $http.post(
      "/signup",
      name: $scope.name
      email: $scope.email
      reason: $scope.reason
    )
    .success () ->
      $scope.name = $scope.email = $scope.reason = ""
      $scope.alertClass = 'success'
      $scope.sendStatus = 'Your request has been sent!'
    .error ->
      $scope.alertClass = 'danger'
      $scope.sendStatus = 'There was an error sending your request!'

  $scope.clearStatus = ->
    $scope.sendStatus = null
  
