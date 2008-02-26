class SecureController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_required
  
  def index
    render :text => 'This is the index page in SecureController'
  end
end
