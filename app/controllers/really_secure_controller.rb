class ReallySecureController < SecureController
  permit "site_admin or moderator"
  
  def index
    render :text => 'This is the index of the ReallySecureController', :layout => true
  end
end
