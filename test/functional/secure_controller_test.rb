require File.dirname(__FILE__) + '/../test_helper'
require 'secure_controller'

# Re-raise errors caught by the controller.
class SecureController; def rescue_action(e) raise e end; end

class SecureControllerTest < Test::Unit::TestCase
  def setup
    @controller = SecureController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
