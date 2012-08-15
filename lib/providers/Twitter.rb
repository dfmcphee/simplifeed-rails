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
        OpenStruct.new({
          :service => 'twitter',
          :who => update.user.name,
          :what => update.text,
          :when => update.created_at
        })
      end
    end
end