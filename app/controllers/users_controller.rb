class UsersController < ApplicationController
  before_filter :authenticate_user!
  # Get stream updates from Facebook, Twitter, and LinkedIn
  def show
    @providers = %w(facebook twitter linkedin)
    if current_user
    	@authorized_providers = Authentication.where(:user_id => current_user.id).pluck(:provider)
    end
    @updates = current_user ? current_user.authentications.where(:provider => @providers).collect {|auth| auth.service.feed }.flatten : []
  end

  # Loop through the checked providers from the form and send the
  # update to each of the services via the Service module.
  def post
    if params[:providers].present?
      providers = current_user.authentications.find_all_by_provider(params[:providers]).collect do |auth|
        auth.service.post(params[:body])
        auth.service.name
      end
      flash[:notice] = "Your message has been posted to #{providers.to_sentence}"
    end
    redirect_to :action => "show"
  end
end
