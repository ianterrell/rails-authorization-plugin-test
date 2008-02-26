require File.dirname(__FILE__) + '/../test_helper'
require 'object_roles_controller'

# Re-raise errors caught by the controller.
class ObjectRolesController; def rescue_action(e) raise e end; end

class ObjectRolesControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @controller = ObjectRolesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_permit?
    get :public_page
    bob = users(:bob)
    bob.is_administrator
    @controller.current_user_set( bob )
    assert @controller.permit?( "administrator" )
    assert !@controller.permit?( "president or poohbah" )
    bush = User.create( :username => 'GW' )
    bush.is_president
    assert !@controller.permit?( "administrator", :user => bush )
    assert @controller.permit?( "president or poohbah", :user => bush )
    assert !@controller.permit?("'stanford alum' or environmentalist or (president and administrator)")
  end
  
  def test_permit
    get :public_page
    bob = users(:bob)
    bob.is_tester
    @controller.current_user_set( bob )
    assert_equal "it works", 
        @controller.permit( "tester" ) { "it works" }
    assert_not_equal "it works", 
        @controller.permit( "administrator", :redirect => false ) { "it works" }
  end
  
  def test_optional_model_colon
    get :public_page
    bob = users(:bob)
    @controller.current_user_set( bob )
    testers = Group.find_or_create_by_name('testers')
    @controller.instance_variable_set(:@testers, testers)
    assert !@controller.permit?( "newbie of testers" )
    bob.is_newbie_of testers
    assert bob.is_newbie_of?( testers )
    assert @controller.permit?( "newbie of :testers" )
    assert @controller.permit?( "newbie of testers" )
  end
end
