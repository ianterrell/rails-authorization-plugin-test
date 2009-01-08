class RestController < ApplicationController
  permit 'owner of :object', :only => :show
  attr_accessor :object_owner

  def index
    render :text => ''
  end

  def show
    object
    render :text => ''
  end

  def object
    AuthorizableObject.new(object_owner)
  end
end

class AuthorizableObject
  def initialize(owner)
    @owner = owner
  end

  def accepts_role?(role, user)
    user == @owner
  end
end
