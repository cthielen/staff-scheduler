describe "ScheduleCtrl", ->
  $scope       = null
  $controller  = null
  $httpBackend = null

  beforeEach module('scheduler')

  beforeEach inject ($injector) ->
    $scope       = $injector.get('$rootScope').$new()
    $controller  = $injector.get('$controller')
    $httpBackend = $injector.get('$httpBackend')
    # $httpBackend.when('GET','/posts.json').respond($fixture)

  it "renders fullCalendar", ->
    $controller(ScheduleCtrl, {$scope: $scope})
    debugger
    
    # controller = new ScheduleCtrl(scope)
    #expect( scope.posts.length ).toBe(3)
