class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_online_friends
  
  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])
    
    @notifications = Notification.where(:user_id => current_user.id, :target_id => @post.id, :target_type => :post, :read => false)
    @notifications.each do | notification |
	    if notification != nil?
	    	notification.read = true
	    	notification.save
	    end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  def mentions
  	 @providers = %w(facebook twitter)
    if current_user
    	@authorized_providers = Authentication.where(:user_id => current_user.id).pluck(:provider)
    end
    @updates = []
    friends = current_user.inverse_friends.map(&:id) + current_user.friends.map(&:id) + [current_user.id]
    
    @mentions = current_user.mentions.map(&:post_id)
    @simplifeed = Post.where(:id => @mentions)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: {'feed' => @simplifeed} }
    end
  end
  
  def favs
  	@providers = %w(facebook twitter)
    if current_user
    	@authorized_providers = Authentication.where(:user_id => current_user.id).pluck(:provider)
    end
    @users = User.find(:all, :select=>'username').map(&:username)
    friends = current_user.inverse_friends.map(&:id) + current_user.friends.map(&:id) + [current_user.id]
    likes = Like.where(:user_id => current_user.id).map(&:post_id)
    @simplifeed = Post.find(:all, :order => "created_at DESC", :limit => 10, :conditions => ['id IN (?)', likes])
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: {'feed' => @simplifeed} }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new
    @upload  = Upload.new
    @uploads = Upload.all
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    @upload  = Upload.new
    @uploads = Upload.all
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])
   
    @links = @post.content.split(/\s+/).find_all { |u| u =~ /^https?:/ }

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'users', :action => 'show'  }
      format.json { head :no_content }
    end
  end
  
  def create_upload
  	 @upload = Upload.new(params[:image_form])
	 @upload.save
	 render :text => @upload.picture_file_name  
  end
  
  def like_post
  	if (params[:post_id] != '')
  		@post = Post.find(params[:post_id])
  		if @post != nil
  			# Create new like for post with id
  			@like = Like.new 
  			@like.post_id = @post.id 
  			@like.user_id = current_user.id
  			@like.save
  			
  			# Notify owner of post about like
  			if @post.user != current_user
	  			user = User.find(@post.user_id)
	  			message = current_user.username + " liked your post. " + view_context.link_to("View", :controller => "posts", :action => "show", :id => @post.id) + " "
	
	  			save_notification(user.id, message, 'info', 'post', @post.id)
  			end
  		end
  	end
  	redirect_to :controller => "users", :action => "show"
  end
  
end
