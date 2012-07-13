class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :lastseenable

  attr_accessor :login

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :username, :first_name, :last_name, :password, :password_confirmation, :remember_me, :name, :image_url, :url, :photo
  
  has_attached_file :photo,
    :styles => {
      :thumb=> "100x100#",
      :small  => "150x150>" }
  
  has_many :authentications
  has_many :notifications
  has_many :posts
  has_many :likes

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  has_many :pending_friends, :through => :friendships, :conditions => "approved = false", :foreign_key => "user_id", :source => :user
  has_many :requested_friendships, :class_name => "Friendship", :foreign_key => "friend_id", :conditions => "approved = false"
  
  validates_uniqueness_of :username
  
  def to_param
    username
  end
  
  def online?
    if self.last_seen != nil
  	  if (self.last_seen.utc < 5.minutes.ago)
        return true;
      else
        return false;
      end
    else
    	return false;
    end
  end
  
  protected
  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    where(conditions)
    .where(["username = :login OR email = :login", 
         {:login => login}])
    .first
  end
  
end
