class Post < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  has_many :likes
  
  has_many :uploads, :dependent => :destroy
  accepts_nested_attributes_for :uploads, :allow_destroy => true
end
