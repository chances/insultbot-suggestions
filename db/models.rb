class User < ActiveRecord::Base
  validate :username, :email, :password, :presence => true
  self.table_name = "insults_users"

  has_many :insults, :inverse_of => :user, :foreign_key => 'author_id'
  
  def self.authenticate(query, attempted_password)
    user = (query.include? '@') ? self.where('email = ?', query) : self.where('username = ?', query)
    user = user.first
    user if user && user.password == attempted_password
  end
end

class Insult < ActiveRecord::Base
  validate :insult, :author_id, :presence => true
  
  belongs_to :user, :inverse_of => :insults, :foreign_key => 'author_id'
  
  def self.approved
    where('approved' => true)
  end

  def self.published
    where('published' => true)
  end
end
