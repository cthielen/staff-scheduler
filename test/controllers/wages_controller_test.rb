require 'test_helper'

class WagesControllerTest < ActionController::TestCase
  setup do
    @wage = wages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wage" do
    assert_difference('Wage.count') do
      post :create, wage: { amount: @wage.amount, employee_id: @wage.employee_id, starting_date: @wage.starting_date }
    end

    assert_redirected_to wage_path(assigns(:wage))
  end

  test "should show wage" do
    get :show, id: @wage
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wage
    assert_response :success
  end

  test "should update wage" do
    patch :update, id: @wage, wage: { amount: @wage.amount, employee_id: @wage.employee_id, starting_date: @wage.starting_date }
    assert_redirected_to wage_path(assigns(:wage))
  end

  test "should destroy wage" do
    assert_difference('Wage.count', -1) do
      delete :destroy, id: @wage
    end

    assert_redirected_to wages_path
  end
end
