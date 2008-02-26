class AccountController < ApplicationController
  
  def index
  end
  
  def login
    if request.post?
      user = User.authenticate( params[:username], params[:password] )
      if user.nil?
        flash.now[:notice] = 'Username or password is incorrect'
      else
        session[:user] = user.id
        redirect_back_or_goto :action => 'index'
      end
    end
  end
  
  def direct_login
    clear_return_location  # If we choose to go to login, we should redirect to home url or member page
    redirect_to :action =>'login'
  end
  
  def logout
    session[:user] = nil
    redirect_to home_url
  end
  
  ############################
  # Methods useful for testing
  
  def add_role
    if request.post? and current_user
      current_user.has_role( params[:role] )
    end
    redirect_to :action => 'index'
  end
  
  def add_user
    if request.post?
      user = create_user( params[:username] )
      current_user_set( user )
    end
    redirect_to :action => 'index'
  end
  
  def random_user
    session[:user] = get_random_user.id
    redirect_to :action => 'index'
  end
  
  def delete_session
    session[:user] = nil
    redirect_to :action => 'index'
  end
  
  def delete_role
    if current_user
      role = Role.find(params[:id])
      current_user.has_no_role( role.name, role.authorizable )
    end
    redirect_to :action => 'index'
  end
  
  def switch_user
    user = create_user( params[:username] )
    current_user_set( user )
    redirect_to :action => 'index'
  end
  
  protected
  
  def create_user( name )
    user = User.find_or_create_by_username( name )
    user.password = name  # For test app, just make password equal to name
    user.save
    user
  end
  
  def get_random_user
    cur_name = current_user ? current_user.username : nil
    begin
      new_name = [
        'David Heinemeier Hansson', 
        'Bill Gates', 
        'Angelina Jolie', 
        'Alexander the Great',
        'Bill',
        'Bob',
        'nobody'
      ].at( rand(7) ) 
    end while ( cur_name == new_name )
    create_user( new_name )
  end
end
