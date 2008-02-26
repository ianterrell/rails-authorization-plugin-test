class Group < ActiveRecord::Base
  acts_as_authorizable

  def accepts_role?( role, user )
    return true if user.username.downcase == 'alexander the great' and role == 'conquerer' and self.name == 'known world'
    super
  end
end
