class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_online_friends
  
  def dismiss_notification
  	if (params[:notification_id] != '')
  		@notification = Notification.find(params[:notification_id])
  		if @notification != nil && @notification.user_id === current_user.id
  			@notification.read = true
  			@notification.save
  		end
  	end
  	redirect_to :action => "show"
  end
  
  
  def filter_post(post)
  	mentions = post.content.scan(/(^|\s)(@\w+)/)
  	
  	mentions.each do |mention|
  		username = mention[1].gsub('@', '')
  		mentioned_user = User.find(:first, :conditions => [ "username = ?", username])
  		if mentioned_user != nil
  			mention = Mention.new
  			mention.user = mentioned_user
  			mention.post = post
  			mention.save!
  			
  			message = current_user.username + " mentioned you. " + 
	view_context.link_to("View", :controller => "posts", :action => "show", :id => post.id)
			save_notification(mentioned_user.id, message, 'info', 'post', post.id)
    	end
  		flash[:notice] = username
  	end
  end

  def save_notification(user_id, message, bootstrap_class, type, target_id)
  	notification = Notification.new
	notification.user_id = user_id
	notification.save
	notification.message = message + " " + view_context.link_to("Dismiss", :controller => "users", :action => "dismiss_notification", :notification_id => notification.id)
	notification.bootstrap_class = bootstrap_class
	
	notification.target_type = type 
	notification.target_id = target_id
	
	if notification.save
		event_id = 'notification-' + user_id.to_s
		Pusher['simplifeed'].trigger(event_id, {:message => notification.message})
	end
	
  end
  
  def is_liked(post_id)
	post_liked = Like.find(:first, :conditions => ['user_id = ? AND post_id = ?', current_user.id, post_id])
	if !post_liked.nil?
		return true;
	else
		return false;
	end
  end
  
  def get_friends
  	# People you have befriended
    friends = current_user.friendships.select { |friend| friend.approved == true }
    friends = friends.map{|friend| friend.friend_id}
    
    # People who befriended you
    inverse_friends = current_user.inverse_friendships.select { |friend| friend.approved == true }
    inverse_friends = inverse_friends.map{|friend| friend.user_id}
    
    friends = friends + inverse_friends
    return friends
  end
  
  def get_online_friends
  	if user_signed_in?
	  	@online_friends = []
	  	friends = get_friends()
  	
	  	@recent_friends = User.find(:all, :limit => 10, :order => "last_seen DESC", :conditions => ['id IN (?)', friends])
	  	
	  	@recent_friends.each do | recent_friend |
	    	if recent_friend.online?
	    		@online_friends.push(recent_friend.id)
	    	end
	    end
    end
  end
 
  
end