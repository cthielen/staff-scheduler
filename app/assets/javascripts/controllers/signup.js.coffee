Welcome.controller "SignupCtrl", @SignupCtrl = ($scope, $http) ->
  $scope.sendStatus = null
  $scope.alertClass = ''
  $scope.sendBtn = 'Send'
  
  $scope.SendRequest = ->
    $scope.sendBtn = 'Sending...'
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
      $scope.sendBtn = 'Send'
    .error ->
      $scope.alertClass = 'danger'
      $scope.sendStatus = 'There was an error sending your request!'
      $scope.sendBtn = 'Try again'

  $scope.clearStatus = ->
    $scope.sendStatus = null
  
