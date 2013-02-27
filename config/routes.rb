Simplifeed::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end
  
  root :to => 'home#index'
  
  # Callback and failure for providers
  match '/users/auth/:provider/callback' => 'authentications#create'
  match '/users/auth/failure' => 'authentications#failure'

  # Used for connecting facebook, etc. with an existing username/password account
  match '/connect/:provider' => 'authentications#connect'
  
  # Main feed
  match '/feed' => 'users#show'
  
  # Twitter feed
  match '/twitter' => 'posts#twitter'
  
  # Facebook feed
  match '/facebook' => 'posts#facebook'
  
  # Mentions
  match '/mentions' => 'posts#mentions'
  
  # Favs
  match '/favs' => 'posts#favs'
  
  # Devise
  devise_for :users do
    get '/users/sign_out' => "devise/sessions#destroy", :as => :destroy_user_session
    match '/users/show' => 'users#show'
  end
  
  # API and tokens
  namespace :api do
    namespace :v1  do
      resources :tokens,:only => [:create, :destroy]
    end
  end

  # Twitter, Facebook, and LinkedIn feeds
  match '/user/post' => 'users#post'
  
  # Update post content
  match '/user/update_post' => 'users#update_post'
  
  # Reply to post
  match '/user/reply_to_post' => 'users#reply_to_post'
  
  # List users, find friends
  match '/friends' => 'users#list'
  
  # List recent chat and get online users
  match '/chat' => 'users#online_friends'
  
  # Like post
  match '/like_post' => 'posts#like_post'
  
  # Send message
  match '/send_message' => 'messages#send_message'
  
  # Request friendship
  match '/user/request_friendship' => 'users#request_friendship'
  
  # Unfriend
  match '/user/unfriend' => 'users#unfriend'
  
  # Approve friendship
  match '/user/approve_friendship' => 'users#approve_friendship'
  
  # Mark message read
  match '/user/dismiss_notification' => 'users#dismiss_notification'
  
  # Dismiss notification
  match '/mark_as_read' => 'messages#mark_as_read'
  
  # Proxy requests
  match '/links/proxy' => 'links#proxy'

  # Resources for posts
  resources :posts
  
  # Get profiles by username
  get "/:id", :to => "users#profile", :as => :user, :constraints => { :id => /.*/ }
  
  resources :links do
    match ':in_url' => 'links#go' #added this line
  end


  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
