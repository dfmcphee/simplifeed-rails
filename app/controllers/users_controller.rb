class UsersController < ApplicationController
  before_filter :authenticate_user!
	
  # Get stream updates from Facebook, Twitter, and LinkedIn
  def show
    @providers = %w(facebook twitter)
    if current_user
    	@authorized_providers = Authentication.where(:user_id => current_user.id).pluck(:provider)
    end
    @updates = current_user ? current_user.authentications.where(:provider => @providers).collect {|auth| auth.service.feed }.flatten : []
    friends = current_user.inverse_friends.map(&:id) + current_user.friends.map(&:id) + [current_user.id]

    @users = User.find(:all, :select=>'username').map(&:username)
    
    @simplifeed = Post.find(:all, :order => "created_at DESC", :limit => 10, :conditions => ['user_id IN (?)', friends])
  end
  
  def list
    @users = User.find(:all, :select=>'username').map(&:username)
    
    # People who want to be your friend
    @incoming = current_user.requested_friendships
    @incoming_requests = @incoming.map{|request| request.user_id}
    @incoming_requests = User.find_all_by_id(@incoming_requests)
    
    # People you have requested to be friends with
    @requested_friends = current_user.friendships.select { |friend| friend.approved == false }
    @requested_friends = @requested_friends.map{|request| request.friend_id}
    @requested_friends = User.find_all_by_id(@requested_friends)
    
    # People you have befriended
    @friends = current_user.friendships.select { |friend| friend.approved == true }
    @friends = @friends.map{|friend| friend.friend_id}
    @friends = User.find_all_by_id(@friends)
    
    # People who befriended you
    @inverse_friends = current_user.inverse_friendships.select { |friend| friend.approved == true }
    @inverse_friends = @inverse_friends.map{|friend| friend.user_id}
    @inverse_friends = User.find_all_by_id(@inverse_friends)
    
    @friends = @friends + @inverse_friends
  end

  # Loop through the checked providers from the form and send the
  # update to each of the services via the Service module.
  def post
    if params[:providers].present?
      providers = current_user.authentications.find_all_by_provider(params[:providers]).collect do |auth|
        auth.service.post(params[:body])
        auth.service.name
      end
      @alert_style = 'success'
      flash[:notice] = "Your message has been posted to #{providers.to_sentence}"
    end
    
	user = current_user
	content = params[:body]

	@post = Post.new
	@post.user_id = user.id
	@post.content = content
	@post.user_thumbnail = current_user.image_url

	if @post.save
		filter_post(@post)
		@alert_style = 'success'
		flash[:notice] = "Post added to Simplifeed."
	else
		@alert_style = 'error'
		flash[:notice] = "Your post could not be saved."
	end
	
    redirect_to :action => "show"
  end
  
  def request_friendship
  	if (params[:friend_username] != '')
	  	@friend = User.find_by_username(params[:friend_username])
	  	if @friend != nil
		  	if @friend.id != current_user.id
		  		@past_friendship = Friendship.find(:first, :conditions => [ "user_id = ? AND friend_id = ?", @friend.id, current_user.id])
		  		if @past_friendship == nil
				  	@friendship = current_user.friendships.build(:friend_id => @friend.id)
				  	
				  	if @friendship.save
				  		message = current_user.username + " would like to be your friend." + view_context.link_to("Approve", :controller => "users", :action => "approve_friendship", :friendship_id => @friendship.id) + " "
						save_notification(@friend.id, message, 'info')
						@alert_style = 'success'
						flash[:notice] = "A friend request has been sent."
					else
						@alert_style = 'error'
						flash[:notice] = "An error occured and your friend request could not be sent."
					end
				else
				  @alert_style = 'error'
				  flash[:notice] = "You have already sent a friend request to this user."
				end
			else
				@alert_style = 'error'
				flash[:notice] = "You cannot add yourself as a friend."
			end
		else
			@alert_style = 'error'
			flash[:notice] = "No user was found with that username."
		end

	  else
	  	@alert_style = 'error'
	  	flash[:notice] = "You didn't enter a username."
	  end
	  redirect_to :action => "list"
  end
  
  def approve_friendship
  	if (params[:friendship_id] != '')
	  @friendship = Friendship.find(params[:friendship_id])
	  if @friendship.friend_id == current_user.id
	  	@friendship.approved = true
	  	if @friendship.save
	  		@friend = User.find(@friendship.user_id)
	  		@alert_style = 'success'
			flash[:notice] = "You and " + @friend.username + " are now friends."
		else
			@alert_style = 'error'
			flash[:notice] = "An error occured and your friend request could not be approved."
		end
	  else
	    @alert_style = 'error'
	    flash[:notice] = "This request was not for you."
	  end
	else
	  @alert_style = 'error'
	  flash[:notice] = "No friend request was found."
	end
	redirect_to :action => "list"
  end
  
  def dismiss_notification
  	if (params[:notification_id] != '')
  		@notification = Notification.find(params[:notification_id])
  		if @notification != nil
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
  			message = current_user.username + " mentioned you. " + 
	view_context.link_to("View", :controller => "posts", :action => "show", :id => post.id)
			save_notification(mentioned_user.id, message, 'info')
    	end
  		flash[:notice] = username
  	end
  end

  def save_notification(user_id, message, bootstrap_class)
  	notification = Notification.new
	notification.user_id = user_id
	notification.save
	notification.message = message + " " + view_context.link_to("Dismiss", :controller => "users", :action => "dismiss_notification", :notification_id => notification.id)
	notification.bootstrap_class = bootstrap_class
	
	if notification.save
		event_id = 'notification-' + user_id.to_s
		Pusher['simplifeed'].trigger(event_id, {:message => notification.message})
	end
	
  end

end
