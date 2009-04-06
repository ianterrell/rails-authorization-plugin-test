require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def test_set_and_unset_role
    oreilly_hackers = Group.create( :name => 'Hacker of Year' )
    dhh = users(:david)
    dhh.has_role 'winner', oreilly_hackers
    winning_role = dhh.roles.find_by_name( 'winner' )
    assert winning_role
    assert_equal oreilly_hackers.id, winning_role.authorizable_id
    assert_equal 'Group', winning_role.authorizable_type
    role = dhh.roles.find_by_name( 'winner' )
    assert_equal role.authorizable, oreilly_hackers
    assert_equal role.name, 'winner'
    
    dhh.has_no_role 'winner', oreilly_hackers
    assert !dhh.roles.find_by_name( 'winner' )
  end
  
  def test_correct_role_handling
    bill = users(:bill)
    bill.has_role('zorro')
    num_roles = Role.count
    bill.has_role('zorro')
    bill.has_role('zorro')
    bill.has_role('zorro')
    bill.has_role('zorro')
    assert num_roles, Role.count
    angelina = users(:angelina)
    angelina.has_role('zorro')
    assert angelina.roles.find_by_name('zorro')
    angelina.has_role? 'zorro'
    assert_equal num_roles, Role.count
    angelina.has_no_role('zorro')
    assert_equal num_roles, Role.count
    assert !angelina.roles.find_by_name('zorro')
    
    ruby_mtg = Meeting.create(:name => 'Ruby')
    bill.has_role 'attendee', ruby_mtg
    num_roles += 1
    assert_equal num_roles, Role.count
    assert !angelina.has_role?( 'attendee' )
    assert bill.has_role?( 'attendee', ruby_mtg )
    angelina.has_role 'attendee', ruby_mtg
    assert_equal num_roles, Role.count
    assert ruby_mtg.accepts_role?( 'attendee', angelina )
    angelina.has_no_role 'attendee', ruby_mtg
    assert !ruby_mtg.accepts_role?( 'attendee', angelina )
    assert ruby_mtg.accepts_role?( 'attendee', bill )

    # We test this because of a possible bug in Ruby (and because above only covers single role handling)
    # Try this in the console and see what I mean:
    # array = ['a','b','c']; array.each { |ar| array.delete(ar) }; puts array.inspecr
    # We expect array to be empty after running that, but on some systems we get back ['b']
    rails_mtg = Meeting.create(:name => 'Rails')
    david = users(:david)
    role_names = ['keynoter', 'speaker', 'presenter', 'q_and_a']
    role_names.each { |role_name| david.has_role(role_name, rails_mtg) }
    assert_equal 4, david.roles.size
    role_names.each { |role_name| david.has_no_role(role_name, rails_mtg) }
    assert_equal 0, david.roles.size
  end
  
  def test_identity_sugar
    steve = User.create( :username => 'Steve' )
    assert steve.is_not_moderator?
    steve.is_moderator
    assert steve.is_moderator?
    assert_equal steve.roles.find_by_name('moderator'), 
      Role.find( :first, :conditions => ['name = ? and authorizable_type IS NULL and authorizable_id IS NULL', 'moderator'])
    steve.is_not_moderator
    assert !steve.is_moderator?
    assert !steve.roles.find_by_name('moderator')
    
    rails_conf = Meeting.create( :name => 'RailsConf 2006' )
    steve.is_participant_in rails_conf
    assert steve.is_participant_in?( rails_conf )
    assert_equal steve.roles.find_by_name('participant'),
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'participant', 'Meeting', rails_conf.id])
    
    ruby_conf = Meeting.create( :name => 'RubyConf 2006' )
    steve.is_participant_in ruby_conf
    meetings = steve.is_participant_in_what
    assert_equal 2, meetings.length
    assert meetings.include?( rails_conf )
    assert meetings.include?( ruby_conf )
    
    bill = users(:bill)
    bill.is_participant_in rails_conf
    assert bill.is_participant?
    participants = rails_conf.has_participants
    assert_equal 2, participants.length
    assert participants.include?( steve )
    assert participants.include?( bill )
    
    steve.is_not_participant_in ruby_conf
    assert_equal 1, steve.is_participant_in_what.length
    assert !steve.is_participant_in?( ruby_conf )
      
    steve.is_not_participant_in rails_conf
    assert !steve.is_participant?
    assert !steve.is_participant_in?( rails_conf )
    assert !steve.roles.find_by_name('participant')
    
    # Test the variant that neglects prepositions
    
    rubyists = Group.create( :name => 'Rubyists' )
    steve.is_loving rubyists
    assert steve.is_loving?
    assert_equal steve.roles.find_by_name('loving'),
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id])
    steve.is_not_loving  # This should do nothing because it's not specific enough (only removes general lovingness)
    assert steve.is_loving?
    assert_equal steve.roles.find_by_name('loving'),
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id])
    steve.is_not_loving rubyists
    assert !steve.is_loving?
    
    mary = User.create( :username => 'Mary' )
    mary.is_owner_of rails_conf
    assert_equal 2, rails_conf.users.size
    assert rails_conf.users.include?(bill)
    assert rails_conf.users.include?(mary)
  end
  
  def test_user_as_authorizable
    steve = User.create( :username => 'Steve' )
    assert steve.is_not_moderator?
    steve.is_moderator
    assert steve.is_moderator?
    assert !steve.is_moderator_for?( User )
    assert_equal steve.roles.find_by_name('moderator'), 
      Role.find( :first, :conditions => ['name = ? and authorizable_type IS NULL and authorizable_id IS NULL', 'moderator'])
    steve.is_not_moderator
    assert !steve.is_moderator?
    assert !steve.roles.find_by_name('moderator')
    
    steve.is_administrator_for User
    assert steve.is_administrator_for?( User )
    assert_equal steve.roles.find_by_name('administrator'),
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id IS NULL', 'administrator', 'User'])
    steve.is_not_administrator_for User
    assert !steve.is_administrator?
    assert !steve.is_administrator_for?( User )
    assert !steve.roles.find_by_name('administrator')
    
    # Back in the day..
    angelina = users(:angelina)
    assert !angelina.has_fans?   # Granted, this is a stretch
    steve.is_fan_of angelina
    assert steve.is_fan_of?( angelina )
    assert steve.is_fan?
    bill = users(:bill)
    bill.is_fan_of angelina
    assert angelina.has_fans?
    fans = angelina.has_fans
    assert_equal 2, fans.length
    assert fans.include?(bill)
    assert fans.include?(steve)
    
    # Steve is disturbed by the relationship between Angelina and Brad Pitt so...
    steve.is_no_fan_of angelina
    assert steve.is_no_fan_of?( angelina )
    assert_equal 1, angelina.has_fans.length
  end

  def test_roles_for
    steve = User.create( :username => 'Steve' )
    rubyists = Group.create( :name => 'Rubyists' )
    ozzies = Group.create( :name => 'Ozzies' )
    assert !steve.has_role_for?(nil)
    assert !steve.has_roles_for?(Group)
    assert !steve.has_roles_for?(rubyists)
    assert !rubyists.accepts_roles_by?(steve)
    assert !ozzies.accepts_roles_by?(steve)
    assert !Group.accepts_roles_by?(steve)
    assert_equal 0, steve.roles_for(nil).size
    assert_equal 0, steve.roles_for(Group).size
    assert_equal 0, steve.roles_for(rubyists).size
    assert_equal 0, rubyists.accepted_roles_by(steve).size
    assert_equal 0, Group.accepted_roles_by(steve).size
    assert_equal 0, steve.authorizables_for(Group).size
    assert_equal 0, Group.authorizables_by(steve).size

    steve.is_moderator
    assert steve.has_role_for?(nil)

    steve.is_loving rubyists
    steve.is_owner_of rubyists
    steve.is_loving ozzies
    assert steve.has_roles_for?(Group)
    assert steve.has_roles_for?(rubyists)
    assert steve.has_roles_for?(ozzies)
    assert rubyists.accepts_roles_by?(steve)
    assert ozzies.accepts_roles_by?(steve)
    assert Group.accepts_roles_by?(steve)

    roles = steve.roles_for(nil)
    assert_equal 1, roles.size
    assert_equal "moderator", roles[0].name

    roles = steve.roles_for(Group)
    assert_equal 3, roles.size
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id]))
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'owner', 'Group', rubyists.id]))
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', ozzies.id]))
        
    roles = steve.roles_for(rubyists)
    assert_equal 2, roles.size
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id]))
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'owner', 'Group', rubyists.id]))

    roles = rubyists.accepted_roles_by(steve)
    assert_equal 2, roles.size
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id]))
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'owner', 'Group', rubyists.id]))

    roles = Group.accepted_roles_by(steve)
    assert_equal 3, roles.size
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id]))
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'owner', 'Group', rubyists.id]))
    assert roles.include?(
      Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', ozzies.id]))

    groups = steve.authorizables_for(Group)
    assert_equal 2, groups.size
    groups.include? rubyists
    groups.include? ozzies

    group = Group.authorizables_by(steve)
    assert_equal 2, groups.size
    groups.include? rubyists
    groups.include? ozzies
  end

  # When an authorizable is destroyed it should also remove any roles that refer to it
  def test_destroy_authorizable
    steve = User.create( :username => 'Steve' )
    rubyists = Group.create( :name => 'Rubyists' )
    steve.is_loving rubyists
    role = Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id])
    assert !role.nil?
    assert_equal 1, ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM roles_users WHERE user_id = #{steve.id} AND role_id = #{role.id}").to_i

    rubyists.destroy
    # the role must have been destroyed as well
    assert Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id]).nil?
    # and the link to the authorizable doesn't exist anymore
    assert_equal 0, ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM roles_users WHERE user_id = #{steve.id} AND role_id = #{role.id}").to_i
    assert_equal steve, User.find(steve.id)
  end

  # When a user is destroyed it should remove the links to its role as well
  def test_destroy_user
    steve = User.create( :username => 'Steve' )
    rubyists = Group.create( :name => 'Rubyists' )
    steve.is_loving rubyists
    role = Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id])
    assert !role.nil?
    assert_equal 1, ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM roles_users WHERE user_id = #{steve.id} AND role_id = #{role.id}").to_i

    steve.destroy
    # the role still exists
    assert !Role.find( :first, :conditions => ['name = ? and authorizable_type = ? and authorizable_id = ?', 'loving', 'Group', rubyists.id]).nil?
    # but the link to the user doesn't exist anymore
    assert_equal 0, ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM roles_users WHERE user_id = #{steve.id} AND role_id = #{role.id}").to_i
  end

  def test_roles_on_unsaved_user
    u = User.new :username=>"bill"
    assert_equal false, u.is_zorro?
    u.is_zorro
    assert_equal true, u.is_zorro?
  end
  
  def test_has_no_roles
    bill = users(:bill)
    angelina = users(:angelina)
    bill.has_role('zorro')
    angelina.has_role('zorro')
    bill.has_no_roles
    # Check that removing all roles for bill doesn't affect angelina
    assert angelina.has_role?('zorro')
  end
end
