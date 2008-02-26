require File.dirname(__FILE__) + '/../test_helper'
require 'really_secure_controller'

# Re-raise errors caught by the controller.
class ReallySecureController; def rescue_action(e) raise e end; end

class ReallySecureControllerTest < Test::Unit::TestCase
  def setup
    @controller = ReallySecureController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
