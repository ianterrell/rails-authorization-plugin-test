require 'digest/sha2'

class User < ActiveRecord::Base
  acts_as_authorized_user
  acts_as_authorizable
  
  validates_uniqueness_of :username
  
  def self.authenticate( username, password )
    user = User.find( :first, :conditions => ['username = ?', username] )
    (user.nil? or user.invalid_password?(password)) ? nil : user
  end
  
  def password=( passwd )
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_salt, self.password_hash = 
      salt, Digest::SHA256.hexdigest( passwd + salt )
  end
  
  def invalid_password?( password )
    Digest::SHA256.hexdigest( password + self.password_salt ) != self.password_hash
  end
  
  # Defining has_role? is optional when you use 'acts_as_authorized_user'.
  # You can check roles against hardwired names before passing it off to default role checking.
  def has_role?( role, authorized_object = nil )
    return true if self.username.downcase == 'bill' and (role == 'bill' or role == 'site_admin')
    return true if self.username.downcase == 'nobody' and role == 'nobody'
    # Note that no 'conquerer' role is hardwired in, so it must be in role table & checked through mixin has_role? method.
    super
  end
end
