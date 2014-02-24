class User < ActiveRecord::Base
  validate :username, :email, :password, :presence => true
  self.table_name = "insults_users"

  has_many :insults, :inverse_of => :user, :foreign_key => 'author_id', :dependent => :destroy
  
  def handle
    (read_attribute(:alias).nil?)? read_attribute(:username) : read_attribute(:alias)  
  end

  def insults_ordered_by_creation
    insults.order(:created_at)
  end
  
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

  def self.approved_and_published
    where({'approved' => true, 'published' => true})
  end

  def self.awaiting_approval
    where({'approved' => false, 'published' => false}).order(:created_at)
  end

  def self.random
    where({'approved' => true, 'published' => true}).first(:order => "RANDOM()")
  end
end
