class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  before_save :ensure_authentication_token!
  
  devise :database_authenticatable, :token_authenticatable, :omniauthable, :registerable, :recoverable, :rememberable, :trackable, :lastseenable

  attr_accessor :login
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :username, :first_name, :last_name, :password, :password_confirmation, :token_authenticatable, :remember_me, :name, :image_url, :url, :photo
  
  has_attached_file :photo,
    :styles => {
      :thumb=> "100x100#",
      :small  => "250x250>" }
  
  has_many :authentications
  has_many :notifications
  has_many :posts
  has_many :likes
  has_many :mentions

  has_many :friendships
  has_many :friends, :through => :friendships,  :conditions => ['friendships.approved = ?',true]
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user, :conditions => ['friendships.approved = ?',true]
  has_many :pending_friends, :through => :friendships, :conditions => "approved = false", :foreign_key => "user_id", :source => :user
  has_many :requested_friendships, :class_name => "Friendship", :foreign_key => "friend_id", :conditions => "approved = false"
  
  validates :email, :presence => true, 
  					:uniqueness => true,
  					:length => {:minimum => 3, :maximum => 254},
                    :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
                    
  validates :username, :presence => true, :uniqueness => true
  validates :password, :confirmation => true
  validates :password_confirmation, :presence => true, :on => :create
  
  def to_param
    username
  end
  
  def online?
  	  self.last_seen > 5.minutes.ago
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
