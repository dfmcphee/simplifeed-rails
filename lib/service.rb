require 'ostruct'
require 'nokogiri'
require 'google_spreadsheet'

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
        OpenStruct.new({
          :service => 'twitter',
          :who => update.user.name,
          :pic => update.user.profile_image_url,
          :what => update.text,
          :when => update.created_at
        })
      end
    end
  end

  class Linkedin < Service::Base
    def initialize(auth)
      super
      @client = ::LinkedIn::Client.new
      @client.authorize_from_access(@token, @secret)
    end

    def post(body)
      @client.update_status(body)
    end

    def feed
      @client.network_updates.updates.select {|u| u.update_type == 'STAT' }.collect do |update|
        OpenStruct.new({
          :service => 'linkedin',
          :who => "#{update.profile.first_name} #{update.profile.last_name}",
          :what => update.profile.current_status,
          :when => Time.at(update.timestamp / 1000)
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
          [update['name'], update['description']].compact.join(': ')
        else
          update['message']
        end
        
        pic = @client.get_picture(update['from']['id'])
        
        OpenStruct.new({
          :service => 'facebook',
          :who => update['from']['name'],
          :pic => pic,
          :what => message,
          :when => Time.parse(update['updated_time']),
          :image => update['picture'],
          :link => update['link']
        })
      end
    end
  end

  class Google < Service::Base
    def initialize(auth)
      super
      @client = OAuth::AccessToken.new(GoogleConsumer, auth.token, auth.secret)
    end

    # This method pulls all the user's documents (spreadsheets, presentations, etc.)
    def documents
      doc = Nokogiri::XML(@client.get('https://docs.google.com/feeds/documents/private/full').body)
      doc.css('entry').collect do |d|
        OpenStruct.new({
          :title => d.css('title').text,
          :link => d.css('link[rel=alternate]')[0]['href'],
          :author => d.css('author name').text,
          :created => Time.parse(d.css('published').text),
          :updated => Time.parse(d.css('updated').text)
        })
      end
    end

    # See the google_spreadsheet gem for more info on interacting
    # with spreadsheets
    def spreadsheets(query = {})
      GoogleSpreadsheet.login_with_oauth(@client).spreadsheets(query)
    end

    def spreadsheet(key)
      GoogleSpreadsheet.login_with_oauth(@client).spreadsheet_by_key(key)
    end
  end
end
