require File.dirname(__FILE__) + '/../test_helper'
require 'rest_controller'

# Re-raise errors caught by the controller.
class RestController; def rescue_action(e) raise e end; end

class RestControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = RestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_denied
    get :index
    bob = users(:bob)
    @controller.current_user_set( bob )
    get :show
    assert_redirected_to '/account/login'
  end

  def test_show_permitted
    get :index
    bob = users(:bob)
    @controller.current_user_set( bob )
    @controller.object_owner = bob
    get :show
    assert_response :success
  end
end
