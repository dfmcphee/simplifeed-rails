class Notification < ActiveRecord::Base
  attr_accessible :class, :message, :user_id
  belongs_to :user
end
