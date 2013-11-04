require 'test_helper'

class EmployeeAvailabilitiesControllerTest < ActionController::TestCase
  setup do
    @employee_availability = employee_availabilities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employee_availabilities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create employee_availability" do
    assert_difference('EmployeeAvailability.count') do
      post :create, employee_availability: { employee_id: @employee_availability.employee_id, end_datetime: @employee_availability.end_datetime, start_datetime: @employee_availability.start_datetime }
    end

    assert_redirected_to employee_availability_path(assigns(:employee_availability))
  end

  test "should show employee_availability" do
    get :show, id: @employee_availability
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @employee_availability
    assert_response :success
  end

  test "should update employee_availability" do
    patch :update, id: @employee_availability, employee_availability: { employee_id: @employee_availability.employee_id, end_datetime: @employee_availability.end_datetime, start_datetime: @employee_availability.start_datetime }
    assert_redirected_to employee_availability_path(assigns(:employee_availability))
  end

  test "should destroy employee_availability" do
    assert_difference('EmployeeAvailability.count', -1) do
      delete :destroy, id: @employee_availability
    end

    assert_redirected_to employee_availabilities_path
  end
end
