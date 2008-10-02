require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  #fixtures :groups
  fixtures :users

  def setup
    @ruby_on_rails = Group.create( :name => 'Ruby on Rails Developers' )
    dhh = users(:david)
    dhh.has_role 'site_admin', @ruby_on_rails
    bill = users(:bill)
    bill.has_role 'admin', @ruby_on_rails
    bob = users(:bob)
    bob.has_role 'member', @ruby_on_rails
  end

  def test_group_has_site_admins_boolean
    assert_equal true, @ruby_on_rails.has_site_admin?
    assert_equal true, @ruby_on_rails.has_site_admins?
  end

  def test_group_has_site_admins_array
    assert_equal 1, @ruby_on_rails.has_site_admin.size
    assert_kind_of User, @ruby_on_rails.has_site_admin.first
    assert_equal 1, @ruby_on_rails.has_site_admins.size
    assert_kind_of User, @ruby_on_rails.has_site_admins.first
  end

  def test_group_has_site_admins_or_admins_or_members_boolean
    assert_equal true, @ruby_on_rails.has_site_admin_or_admin_or_member?
    assert_equal true, @ruby_on_rails.has_site_admins_or_admins_or_members?
  end

  def test_group_has_site_admins_or_admins_or_members_array
    assert_equal 3, @ruby_on_rails.has_site_admin_or_admin_or_member.size
    assert_kind_of User, @ruby_on_rails.has_site_admin_or_admin_or_member.first
    assert_equal 3, @ruby_on_rails.has_site_admins_or_admins_or_members.size
    assert_kind_of User, @ruby_on_rails.has_site_admins_or_admins_or_members.first
  end

  def test_group_doesnt_have_any_moderators_boolean
    assert_equal false, @ruby_on_rails.has_moderator?
    assert_equal false, @ruby_on_rails.has_moderators?
  end

  def test_group_doesnt_have_any_moderators_array
    assert_equal 0, @ruby_on_rails.has_moderator.size
    assert_equal 0, @ruby_on_rails.has_moderators.size
  end

end
