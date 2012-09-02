class DocumentsController < ApplicationController
  before_filter :load_auth
  
  def index
    @docs = @auth.service.documents
    
    # Alternatively, to use the google-spreadsheet-ruby gem:
    # @spreadsheets = @auth.service.spreadsheets
  end
  
  def load_auth
    unless current_user && @auth = current_user.authentications.first(:conditions => { :provider => 'google' })
      session[:oauth_return] = documents_path
      redirect_to('/users/auth/google')
      return false
    end
  end
end