class MessagesController < ApplicationController
  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :no_content }
    end
  end
  
  def send_message
	from = current_user.id
	to = params[:to]
	message = params[:message]
	

	@message = Message.new
	@message.from = current_user.id
	@message.to = to
	@message.content = message

	if @message.save
		@errors = false
		event_id = 'message-' + @message.to.to_s
		Pusher['simplifeed'].trigger(event_id, {:message => @message.content, :friend => from, :friend_username => current_user.username, :time => @message.created_at.strftime("%I:%M %p")})
	else
		@errors = 'Error: Could not send message'
	end
	
	respond_to do |format|
      format.json { render json: @errors }
    end
  end
  
  def mark_as_read
	friend_id = params[:friend_id]

	unread_messages = Message.where(:to => current_user.id, :from => friend_id, :read => false)

	@response = {:success => true, :count => unread_messages.size}
	
	unread_messages.update_all(:read => true)
	
	respond_to do |format|
      format.json { render json: @response }
    end
  end

end
