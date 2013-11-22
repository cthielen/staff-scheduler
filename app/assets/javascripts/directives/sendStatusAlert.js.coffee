Welcome.directive "sendStatusAlert", @sendStatusAlert = () ->
  scope:
      sendStatusAlert: "="
  link: (scope, element, attrs) ->
    scope.$watch "sendStatusAlert", (value) ->
      element.html('<div class="alert alert-success" id="success">Your request has been sent!</div>') if value is 'success'
      element.html('<div class="alert alert-danger" id="error">There was an error sending your request!</div>') if value is 'error'
      element.html('') if value is null
