class UsersController < ApplicationController
  before_filter :authenticate_user!
	
  # Get stream updates from Facebook, Twitter, and LinkedIn
  def show
    @providers = %w(facebook twitter)
    if current_user
    	@authorized_providers = Authentication.where(:user_id => current_user.id).pluck(:provider)
    end
    @updates = []
    friends = current_user.inverse_friends.map(&:id) + current_user.friends.map(&:id) + [current_user.id]

    @users = User.find(:all, :select=>'username').map(&:username)
        
    @simplifeed = Post.find(:all, :order => "created_at DESC", :limit => 10, :conditions => ['user_id IN (?) AND reply_to = ?', friends, 0])
    @upload  = Upload.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: {'feed' => @simplifeed}, :callback => params[:callback] }
    end
  end
  
  def delete 
  	@user = User.find(params[:id])
  	if current_user === @user
  		respond_to do |format|
	  		format.html # new.html.erb
	  		format.json { render json: {'message' => 'Succesfully unsubscribed.', :callback => params[:callback]} }
	  	end
  	end
  end
  
  def online_friends
  	@online_friends = []
  	@unread_messages = Hash.new()
  	friends = get_friends()
  	
  	@recent_friends = User.find(:all, :limit => 10, :order => "last_seen DESC", :conditions => ['id IN (?)', friends])
  	
  	@recent_friends.each do | recent_friend |
    	if recent_friend.online?
    		@online_friends.push(recent_friend.id)
    	end
    	unread_friend_messages = Message.where(:to => current_user.id, :from => recent_friend.id, :read => false)
    	if !unread_friend_messages.empty?
    		@unread_messages[recent_friend.id] = unread_friend_messages.size
    	end
    end
  	
  	
  	respond_to do |format|
      format.html # new.html.erb
      format.json { render json: {'recent' => @recent_friends, 'online' => @online_friends, :unread => @unread_messages, :callback => params[:callback]} }
    end
  end
  
  # Get user profile
  def profile
  	@user = User.find_by_username(params[:id])
  	
  	if @user.id === current_user.id
		@active = 'profile'
	else
		@active = 'other'
	end
  	
  	@providers = %w(facebook twitter)
  	
    if current_user
    	@authorized_providers = Authentication.where(:user_id => current_user.id).pluck(:provider)
    end
    
    @updates = []
    friends = current_user.inverse_friends.map(&:id) + current_user.friends.map(&:id) + [current_user.id]

    @users = User.find(:all, :select=>'username').map(&:username)
  	        
    @simplifeed = Post.find(:all, :order => "created_at DESC", :limit => 10, :conditions => ['user_id = ? AND reply_to = ?', @user.id, 0])
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
    
    @recommendations = []
    
    @friends.each do |f|
		# Mutual friends of a friend	
		friend = User.find(f.id)
		
	    mutual_friends = Friendship.find(:all, :conditions => ["approved = ? AND user_id = ? AND friend_id != ? AND friend_id NOT IN (?) AND friend_id NOT IN (?)", true, friend.id, current_user.id, @friends, @requested_friends])
	    mutual_friends = mutual_friends.map{|friend| friend.friend_id}
	    mutual_friends = User.find_all_by_id(mutual_friends)
	    
	    # Friends of a mutual friend
	    inverse_mutual_friends = Friendship.find(:all, :conditions => ["approved = ? AND friend_id = ? AND user_id != ? AND user_id NOT IN (?) AND user_id NOT IN (?)", true, friend.id, current_user.id, @friends, @requested_friends])
	    inverse_mutual_friends = inverse_mutual_friends.map{|friend| friend.user_id}
	    inverse_mutual_friends = User.find_all_by_id(inverse_mutual_friends)
	    
	    @recommendations = @recommendations + mutual_friends + inverse_mutual_friends
    end
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
    
  def update_post
	user = current_user
	post_id = params[:post_id]
	content = params[:body]
	
	@post = Post.find(post_id)
	
	if @post != nil?
		if @post.user_id === current_user.id
			@post.content = content
	
			if @post.save
				filter_post(@post)
				@alert_style = 'success'
				flash[:notice] = "Post updated."
			else
				@alert_style = 'error'
				flash[:notice] = "Your post could not be saved."
			end
		else
			flash[:notice] = "You are not authorized to update this post."
		end
	else
		flash[:notice] = "Post could not be updated because it could not be found."
	end
	
    redirect_to :action => "show"
  end
  
  def reply_to_post
	user = current_user
	post_id = params[:reply_to]
	content = params[:body]
	
	@post = Post.find(post_id)
	
	@reply = Post.new
	@reply.user_id = user.id
	@reply.content = content
	@reply.user_thumbnail = current_user.image_url
	@reply.reply_to = @post.id

	if @reply.save
		filter_post(@reply)
		@alert_style = 'success'
		flash[:notice] = "Post added to Simplifeed."
		
		if @post.user_id != current_user.id
			message = current_user.username + " commented on your post. " + view_context.link_to("View", :controller => "posts", :action => "show", :id => @post.id)
			save_notification(@post.user_id, message, 'info', 'post', @post.id)
		end
	else
		@alert_style = 'error'
		flash[:notice] = "Your post could not be saved."
	end
	
    redirect_to :action => "show"
  end
  
  
  def delete_post
	user = current_user
	post_id = params[:post_id]
		
    @post = Post.find(post_id)
		
	if @post != nil?
		if @post.user_id === current_user.id
			@post.content = content
	
			if @post.destroy
				filter_post(@post)
				@alert_style = 'success'
				flash[:notice] = "Post deleted."
			else
				@alert_style = 'error'
				flash[:notice] = "Your post could not be deleted."
			end
		else
			flash[:notice] = "You are not authorized to delete this post."
		end
	else
		flash[:notice] = "Post could not be deleted because it could not be found."
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
						save_notification(@friend.id, message, 'info', 'friendship', @friendship.id)
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
	  		@notification = Notification.find(:first, :conditions => ["user_id = ? AND target_id = ? AND target_type = 'friendship'", current_user.id, @friendship.id])

		    if @notification != nil?
		    	@notification.read = true
		    	@notification.save
		    end
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
  
   def unfriend
  	  if (params[:friend_username] != '')
	  	@friend = User.find_by_username(params[:friend_username])
	  	if @friend != nil
	  		@friendship = Friendship.find(:first, :conditions => [ "user_id = ? AND friend_id = ?", @friend.id, current_user.id])
	  		if @friendship.nil?
	  			@friendship = Friendship.find(:first, :conditions => [ "user_id = ? AND friend_id = ?",current_user.id, @friend.id ])
	  		end
	  		if @friendship != nil
			  	@friendship.destroy
			  	flash[:notice] = "You and " + @friend.username + " are no longer friends."
			else
				flash[:notice] = "No friendship was found between you"
			end
		else
			@alert_style = 'error'
			flash[:notice] = "No friend was found with that username."
		end

	  else
	  	@alert_style = 'error'
	  	flash[:notice] = "You didn't enter a username."
	  end
	  redirect_to :action => "list"
  end
  
  def is_friend(user)
	friends = get_friends
    return friends.include?(user.id)
  end
  
  
end
