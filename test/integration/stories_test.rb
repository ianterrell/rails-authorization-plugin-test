# This integration test was built after reading Rails Recipe #43,
# and the style of this test was taken from that recipe.
# Chad Fowler's book "Rails Recipes" is highly recommended.

require "#{File.dirname(__FILE__)}/../test_helper"

class StoriesTest < ActionController::IntegrationTest
  fixtures :users

  def test_not_logged_in
    new_session do |test|
      test.controller 'object_roles' do
        test.cannot_access 'moderate_meeting'
      end
    end
  end

# FIXME : Getting periodic failures with this test in stories_test.rb
#  def test_permit_checks
#    new_session do |test|
#      david = test.login :david
#      test.controller 'object_roles' do
#        test.cannot_access 'dynamic_permit_check', :auth_expr => "foo"
#        david.has_role 'foo'
#        test.can_access 'dynamic_permit_check', :auth_expr => "foo"
#        test.cannot_access 'dynamic_permit_check', :auth_expr => "moo of Group"
#        david.has_role 'moo', Group
#        test.can_access 'dynamic_permit_check', :auth_expr => "moo of Group"
#        test.can_access 'dynamic_permit_check', :auth_expr => "'grand poobah' or moo of Group"
#        test.cannot_access 'dynamic_permit_check', :auth_expr => "'grand poobah' and moo of Group"
#        test.errors 'dynamic_permit_check', :auth_expr => "moo under Group"
#        test.errors 'dynamic_permit_check', :auth_expr => "junk junk"
#        test.errors 'dynamic_permit_check', :auth_expr => "junk BAD_PREPOSITION junk"
#        test.cannot_access 'dynamic_permit_check', :auth_expr => "FALSE_A"
#        test.cannot_access 'dynamic_permit_check', :auth_expr => "FALSE_A and FALSE_B"
#        test.cannot_access 'dynamic_permit_check', :auth_expr => "(FALSE_A and FALSE_B and FALSE_C) or FALSE_D"
#        test.can_access 'dynamic_permit_check', :auth_expr => "((FALSE_A or foo or FALSE_B) and ((moo of Group and foo or FALSE_C) or FALSE_D)) and (moo of Group or FALSE_E)"
#        test.cannot_access 'dynamic_permit_check', :auth_expr => "((FALSE_A or foo or FALSE_B) and ((moo of Group and foo and FALSE_C) or FALSE_D)) and (moo of Group or FALSE_E)"
#        test.errors 'dynamic_permit_check', :auth_expr => "junk &* junk"
#      end
#    end
#  end

  def test_has_role_and_unset
    new_session do |test|
      david = test.login :david
      test.controller 'object_roles' do
        test.cannot_access 'moderate_meeting'
        david.has_role 'moderator'
        test.cannot_access 'moderate_meeting'
        david.has_role 'moderator', Meeting
        david.has_no_role 'moderator', Meeting
        test.cannot_access 'moderate_meeting'

        test.cannot_access 'group_members'
        david.has_role 'site_admin'
        test.can_access 'group_members'
        david.has_no_role 'site_admin'
        test.cannot_access 'group_members'

        hacker = Role.find_by_name('hacker')
        Role.delete(hacker.id) if hacker
        assert Role.find_by_name('hacker').nil?
        david.has_role 'hacker'
        assert !Role.find_by_name('hacker').nil?
        david.has_role 'hacker'
        assert !Role.find_by_name('hacker').nil?  # Removing a role for a user shouldn't delete the actual Role record
      end
    end
  end

  # Check to see if authorization plugin plays nicely with using before_filter :login_required in a superclass
  def test_subclass_authorization
    new_session do |test|
      test.controller 'really_secure' do
        test.cannot_access 'index'
        bill = test.login :bill
        bill.has_role 'site_admin'
        test.can_access 'index'
      end
    end
  end

  def test_angelina
    new_session do |test|
      angelina = test.login :angelina
      test.controller 'object_roles' do
        test.can_access 'public_page'
        test.cannot_access 'nobody_page'
        test.cannot_access 'bill_page'
        test.cannot_access 'conquerer_page'
        test.cannot_access 'moderate_meeting'
        angelina.has_role 'member'
        test.cannot_access 'group_members'
        angelina.has_role 'member', Group
        test.can_access 'group_members'
        angelina.has_no_role 'member', Group
        test.cannot_access 'group_members'
        assert angelina.has_role?( 'member' )
        assert !angelina.has_role?( 'member', Group )
      end
    end
  end

  def test_bill_gates
    new_session do |test|
      gates = test.login :bill_gates
      test.controller 'object_roles' do
        test.can_access 'public_page'
        test.cannot_access 'nobody_page'
        test.cannot_access 'bill_page'
        test.cannot_access 'conquerer_page'
        test.cannot_access 'moderate_meeting'
        test.cannot_access 'group_members'
        test.cannot_access 'moderate_ruby_meeting'
        ruby_meeting = Meeting.find_or_create_by_name( 'Ruby' )
        gates.has_role 'moderator', ruby_meeting
        test.can_access 'moderate_ruby_meeting'
      end
    end
  end

  def test_bob
    new_session do |test|
      bob = test.login :bob
      bob.has_role 'moderator', Meeting
      test.controller 'object_roles' do
        test.can_access 'public_page'
        test.cannot_access 'nobody_page'
        test.cannot_access 'bill_page'
        test.cannot_access 'conquerer_page'
        test.can_access 'moderate_meeting'
        test.cannot_access 'group_members'
      end
    end
  end

  def test_bill
    new_session do |test|
      bill = test.login :bill
      test.controller 'object_roles' do
        test.can_access 'public_page'
        test.cannot_access 'nobody_page'
        test.can_access 'bill_page'
        bill.has_role('conquerer')
        test.cannot_access 'conquerer_page'     # Generic conquerer role is overriden by specific conquerer of known world in Group
        test.cannot_access 'moderate_meeting'
        test.can_access 'group_members'     # Can access because 'site_admin' role is hardwired in.
      end
    end
  end

  def test_nobody
    new_session do |test|
      nobody = test.login :nobody
      test.controller 'object_roles' do
        test.can_access 'public_page'
        test.can_access 'nobody_page'
        test.cannot_access 'bill_page'
        known_world = Group.find_or_create_by_name('known world')
        nobody.has_no_role 'conquerer', known_world
        assert !nobody.has_role?('conquerer', known_world)
        test.cannot_access 'conquerer_page'
        nobody.has_role 'conquerer', known_world
        test.can_access 'conquerer_page'
        test.cannot_access 'moderate_meeting'
        test.cannot_access 'group_members'
      end
    end
  end

  def test_alexander
    new_session do |test|
      alexander = test.login :alexander
      test.controller 'object_roles' do
        test.can_access 'public_page'
        test.cannot_access 'nobody_page'
        test.cannot_access 'bill_page'
        test.can_access 'conquerer_page'  # This is hardwired into Group model
        test.cannot_access 'moderate_meeting'
        test.cannot_access 'group_members'
      end
    end
  end

  private

  module AuthorizationTestDSL

    def login( user_sym )
      user = users( user_sym )
      post "/account/login", :username => user.username, :password => user.username
      assert_response :redirect
      follow_redirect!
      assert_response :success
      user
    end

    def controller( controller_name = '' )
      @@test_controller_name = controller_name
      yield if block_given?
    end

    def can_access( page, args = {})
      get "/#{@@test_controller_name}/#{page}", args
      assert_response :success
      assert_template "layouts/#{@@test_controller_name}"
    end

    def cannot_access( page, args = {})
      get "/#{@@test_controller_name}/#{page}", args
      assert_response :redirect
      follow_redirect!
      assert_template "account/login"
    end

    def errors( page, args = {})
      get "/#{@@test_controller_name}/#{page}", args
      assert_response :error
    end

  end

  def new_session
    open_session do |sess|
      sess.extend( AuthorizationTestDSL )
      yield sess if block_given?
    end
  end
end