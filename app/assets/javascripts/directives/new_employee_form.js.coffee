window.StaffScheduler.directive "newEmployee", ->
  templateUrl: 'assets/partials/new_employee_form.html'
  link: (scope, element, attrs) ->
    $(element).find(".name.typeahead").typeahead
      name: "employees"
      local: [
        'one','two','three'
      ]
  