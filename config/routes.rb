Simplifeed::Application.routes.draw do
  resources :uploads

  root :to => 'users#show'

  resources :notifications

  resources :friendships

  resources :posts

  devise_for :users do
  	get "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  match '/auth/:provider/callback' => 'authentications#create'
  
  match '/auth/failure' => 'authentications#failure'

  # Used for connecting facebook, etc. with an existing username/password account
  match '/connect/:provider' => 'authentications#connect'

  # Twitter, Facebook, and LinkedIn feeds
  match '/user/post' => 'users#post'
  
  # Update post content
  match '/user/update_post' => 'users#update_post'
  
  # List users, find friends
  match '/friends' => 'users#list'
  
  # List recent chat and get online users
  match '/chat' => 'users#online_friends'
  
  # Like post
  match '/like_post' => 'posts#like_post'
  
  # Request friendship
  match '/user/request_friendship' => 'users#request_friendship'
  
  # Approve friendship
  match '/user/approve_friendship' => 'users#approve_friendship'
  
  # Dismiss notification
  match '/user/dismiss_notification' => 'users#dismiss_notification'

  # Google docs
  resources :documents
  
  get "/:id", :to => "users#profile", :as => :user
end