class ObjectRolesController < ApplicationController
  permit "nobody", :only => :nobody_page
  
  def public_page
    render :text => "This is visible to all", :layout => true
  end
  
  def nobody_page
    render :text => "You shouldn't see this, unless you are 'nobody'!", :layout => true
  end
  
  def bill_page
    permit "bill" do
      render :text => "Only Bill should see this page", :layout => true
    end
  end
  
  def conquerer_page
    @group = Group.find_or_create_by_name('known world')
    permit "conquerer of :group" do
      render :text => "Only a 'conquerer' of Group 'known world' should see this page", :layout => true
    end
  end
  
  def moderate_meeting
    permit "moderator of Meeting" do
      render :text => "Only moderators of a meeting should see this", :layout => true
    end
  end
  
  def make_bob_moderator
    bob = User.find_by_username( "Bob" )
    if bob.nil?
      bob = User.create( :username => "Bob", :password => "Bob" )
    end
    bob.has_role "moderator"
    current_user_set( bob )
    redirect_to :controller => 'account', :action => 'index'
  end
  
  def moderate_ruby_meeting
    @meeting = Meeting.find_or_create_by_name('Ruby')
    permit "moderator of :meeting" do
      render :text => "Only moderators of a Ruby meeting should see this", :layout => true
    end
  end

  def make_dhh_moderator_of_Ruby_meeting
    ruby_meeting = Meeting.find_or_create_by_name('Ruby')
    dhh = User.find_by_username( "David Heinemeier Hansson" )
    dhh = User.create( :username => "David Heinemeier Hansson", :password => "David Heinemeier Hansson" ) if dhh.nil?
    ruby_meeting.accepts_role 'moderator', dhh
    current_user_set( dhh )
    redirect_to :controller => 'account', :action => 'index'
  end
  
  def group_members
    permit "site_admin or member of Group" do
      render :text => "Only members of a group (or site_admin) should see this", :layout => true
    end
  end
  
  def dynamic_permit_check
    # OK, you should NOT do this in a real app, but for a pure local test app it's convenient.
    permit params[:auth_expr] do
      render :text => "You can get into this view using authorization expression = '#{params[:auth_expr]}'", :layout => true
    end
  end
  
  def check_optional_colon
    @testers = Group.find_or_create_by_name('testers')
    bob = User.find_by_username( "Bob" )
    if bob.nil?
      bob = User.create( :username => "Bob", :password => "Bob" )
    end
    bob.is_newbie_of @testers
    current_user_set( bob )
    permit "newbie of testers" do
      render :text => "This works", :layout => true
    end
  end
end
