require 'test_helper'

class LocationAssignmentsControllerTest < ActionController::TestCase
  setup do
    @location_assignment = location_assignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:location_assignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location_assignment" do
    assert_difference('LocationAssignment.count') do
      post :create, location_assignment: { employee_id: @location_assignment.employee_id, location_id: @location_assignment.location_id }
    end

    assert_redirected_to location_assignment_path(assigns(:location_assignment))
  end

  test "should show location_assignment" do
    get :show, id: @location_assignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @location_assignment
    assert_response :success
  end

  test "should update location_assignment" do
    patch :update, id: @location_assignment, location_assignment: { employee_id: @location_assignment.employee_id, location_id: @location_assignment.location_id }
    assert_redirected_to location_assignment_path(assigns(:location_assignment))
  end

  test "should destroy location_assignment" do
    assert_difference('LocationAssignment.count', -1) do
      delete :destroy, id: @location_assignment
    end

    assert_redirected_to location_assignments_path
  end
end
