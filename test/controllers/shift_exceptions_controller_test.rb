require 'test_helper'

class ShiftExceptionsControllerTest < ActionController::TestCase
  setup do
    @shift_exception = shift_exceptions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shift_exceptions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shift_exception" do
    assert_difference('ShiftException.count') do
      post :create, shift_exception: { employee_id: @shift_exception.employee_id, end_datetime: @shift_exception.end_datetime, is_absence: @shift_exception.is_absence, shift_id: @shift_exception.shift_id, start_datetime: @shift_exception.start_datetime }
    end

    assert_redirected_to shift_exception_path(assigns(:shift_exception))
  end

  test "should show shift_exception" do
    get :show, id: @shift_exception
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shift_exception
    assert_response :success
  end

  test "should update shift_exception" do
    patch :update, id: @shift_exception, shift_exception: { employee_id: @shift_exception.employee_id, end_datetime: @shift_exception.end_datetime, is_absence: @shift_exception.is_absence, shift_id: @shift_exception.shift_id, start_datetime: @shift_exception.start_datetime }
    assert_redirected_to shift_exception_path(assigns(:shift_exception))
  end

  test "should destroy shift_exception" do
    assert_difference('ShiftException.count', -1) do
      delete :destroy, id: @shift_exception
    end

    assert_redirected_to shift_exceptions_path
  end
end
