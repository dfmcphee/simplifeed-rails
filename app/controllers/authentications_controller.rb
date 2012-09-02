class AuthenticationsController < ApplicationController
  # This action is invoked when a user comes back from a
  # successful authorization at Twitter, Facebook, etc.
  # If the user has logged in with this method before, load the
  # user and update the authentication (if necessary).  Otherwise,
  # create the user.
  def create
    auth = Authentication.find_or_create_from_omniauth(request.env['omniauth.auth'])
    # This logs the user in, if not logged in already, or sets
    # the user for additional authentications to the user that is
    # logged in.  This allows a user to sign up via twitter, then
    # add a twitter login to the same User record.

    auth.create_or_associate_user(current_user)
    redirect_to(session.delete(:oauth_return) || '/')
  end
  
  # Use this as a redirector to force the login before going to a 
  # 3rd party, in order to connect 3rd party accounts to a local
  # account.  Add a before filter, such as authenticate_user! for
  # the connect and create actions to ensure the user is logged
  # in and the authentication gets associated with the logged-in user
  def connect
    session[:oauth_return] ||= request.referer
    redirect_to("/users/auth/#{params[:provider]}")
  end
  
  def failure
    render :text => 'Oops!'
  end
  
end