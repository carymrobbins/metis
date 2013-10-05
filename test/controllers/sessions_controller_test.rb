require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'sign in page' do
    get :new
    assert_select 'body', /Sign in/
    assert_select 'title', /Sign in/
  end
end
