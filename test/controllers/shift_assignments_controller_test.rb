require 'test_helper'

class ShiftAssignmentsControllerTest < ActionController::TestCase
  setup do
    @shift_assignment = shift_assignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shift_assignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shift_assignment" do
    assert_difference('ShiftAssignment.count') do
      post :create, shift_assignment: { employee_id: @shift_assignment.employee_id, end_datetime: @shift_assignment.end_datetime, is_absence: @shift_assignment.is_absence, is_confirmed: @shift_assignment.is_confirmed, shift_id: @shift_assignment.shift_id, start_datetime: @shift_assignment.start_datetime }
    end

    assert_redirected_to shift_assignment_path(assigns(:shift_assignment))
  end

  test "should show shift_assignment" do
    get :show, id: @shift_assignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shift_assignment
    assert_response :success
  end

  test "should update shift_assignment" do
    patch :update, id: @shift_assignment, shift_assignment: { employee_id: @shift_assignment.employee_id, end_datetime: @shift_assignment.end_datetime, is_absence: @shift_assignment.is_absence, is_confirmed: @shift_assignment.is_confirmed, shift_id: @shift_assignment.shift_id, start_datetime: @shift_assignment.start_datetime }
    assert_redirected_to shift_assignment_path(assigns(:shift_assignment))
  end

  test "should destroy shift_assignment" do
    assert_difference('ShiftAssignment.count', -1) do
      delete :destroy, id: @shift_assignment
    end

    assert_redirected_to shift_assignments_path
  end
end
