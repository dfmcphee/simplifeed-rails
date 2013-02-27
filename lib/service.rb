require 'ostruct'

# This is a shim to unify the Twitter, Facebook, and LinkedIn APIs
# for posting and listing updates.
module Service
  class Base
    attr_accessor :client

    def initialize(auth)
      @token = auth.token
      @secret = auth.secret
    end

    def name
      self.class.name.gsub('Service::', '')
    end

    def self.provider(p, auth)
      "Service::#{p.to_s.classify}".constantize.new(auth)
    end
  end

  class Twitter < Service::Base
    def initialize(auth)
      super
      @client = ::Twitter::Client.new(:oauth_token => @token, :oauth_token_secret => @secret)
    end

    def post(body)
      @client.update(body)
    end

    def feed
      @client.home_timeline.collect do |update|
      
      	pic = 'https://api.twitter.com/1/users/profile_image?screen_name=' + update.user.screen_name + '&size=bigger'
      
        OpenStruct.new({
          :service => 'twitter',
          :who => update.user.name,
          :pic => pic,
          :what => update.text,
          :when => update.created_at
        })
      end
    end
  end

  class Facebook < Service::Base
    def initialize(auth)
      super
      @client = Koala::Facebook::API.new(@token)
    end

    def post(body)
      @client.put_object('me', 'feed', :message => body)
    end

    def feed
      @client.get_connections("me", "home").collect do |update|
        
        message = if update['type'] == 'link'
          update['link']
        else
          update['message']
        end
        
        pic = 'http://graph.facebook.com/' + update['from']['id'] + '/picture?type=large'
        
        if update['type'] == 'photo'
        	picture = @client.get_picture(update['object_id'])
        	photo = picture['source']
        else
        	photo = update['picture']
        end
        
        OpenStruct.new({
          :service => 'facebook',
          :who => update['from']['name'],
          :pic => pic,
          :what => message,
          :when => Time.parse(update['updated_time']),
          :image => photo,
          :link => update['link']
        })
      end
    end
  end
end
