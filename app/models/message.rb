class Message < ActiveRecord::Base
  attr_accessible :content, :from, :to
end
