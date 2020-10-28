require 'test_helper'

class AccounttypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @accounttype = accounttypes(:one)
  end

  test "should get index" do
    get accounttypes_url
    assert_response :success
  end

  test "should get new" do
    get new_accounttype_url
    assert_response :success
  end

  test "should create accounttype" do
    assert_difference('Accounttype.count') do
      post accounttypes_url, params: { accounttype: { created_on: @accounttype.created_on, name: @accounttype.name } }
    end

    assert_redirected_to accounttype_url(Accounttype.last)
  end

  test "should show accounttype" do
    get accounttype_url(@accounttype)
    assert_response :success
  end

  test "should get edit" do
    get edit_accounttype_url(@accounttype)
    assert_response :success
  end

  test "should update accounttype" do
    patch accounttype_url(@accounttype), params: { accounttype: { created_on: @accounttype.created_on, name: @accounttype.name } }
    assert_redirected_to accounttype_url(@accounttype)
  end

  test "should destroy accounttype" do
    assert_difference('Accounttype.count', -1) do
      delete accounttype_url(@accounttype)
    end

    assert_redirected_to accounttypes_url
  end
end
