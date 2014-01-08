require 'test_helper'

class ShiftAssignmentStatusesControllerTest < ActionController::TestCase
  setup do
    @shift_assignment_status = shift_assignment_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shift_assignment_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shift_assignment_status" do
    assert_difference('ShiftAssignmentStatus.count') do
      post :create, shift_assignment_status: { name: @shift_assignment_status.name }
    end

    assert_redirected_to shift_assignment_status_path(assigns(:shift_assignment_status))
  end

  test "should show shift_assignment_status" do
    get :show, id: @shift_assignment_status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shift_assignment_status
    assert_response :success
  end

  test "should update shift_assignment_status" do
    patch :update, id: @shift_assignment_status, shift_assignment_status: { name: @shift_assignment_status.name }
    assert_redirected_to shift_assignment_status_path(assigns(:shift_assignment_status))
  end

  test "should destroy shift_assignment_status" do
    assert_difference('ShiftAssignmentStatus.count', -1) do
      delete :destroy, id: @shift_assignment_status
    end

    assert_redirected_to shift_assignment_statuses_path
  end
end
