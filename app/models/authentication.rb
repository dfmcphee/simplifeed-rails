class Authentication < ActiveRecord::Base
  belongs_to :user

  attr_accessible :name, :image_url, :provider_id, :token, :url, :secret, :uid, :provider

  # Pull some info from the omniauth hash
  def self.find_or_create_from_omniauth(oa)
    auth = where(:provider => oa['provider'], :uid => oa['uid']).first || create(:provider => oa['provider'], :uid => oa['uid'])
    info = case oa['provider']
      when 'facebook'
        {
          :name => "#{oa['info']['first_name']} #{oa['info']['last_name']}",
          :url => oa['info']['urls']['Website'] || oa['info']['urls']['Facebook'],
          :image_url => "http://graph.facebook.com/#{oa['uid']}/picture",
          :provider_id  => oa['info']['nickname']
        }
      when 'linkedin'
        {
          :name => "#{oa['info']['first_name']} #{oa['info']['last_name']}",
          :url => oa['info']['urls']['Personal Website'] || oa['info']['urls']['Blog'] || oa['info']['urls'].shift,
          :image_url => oa['info']['image']
        }
      when 'twitter'
        {
          :name => oa['info']['name'],
          :url => oa['info']['urls'].first.try(:second),
          :image_url => oa['info']['image'],
          :provider_id => oa['info']['screen_name']
        }
      else {}
    end

    auth.update_attributes({ :token => oa['credentials']['token'], :secret => oa['credentials']['secret'] }.merge(info))
    auth
  end

  # Associate a new user (creating it, if necessary) with this authentication.
  # Used in AuthenticationsController when signing in.
  def create_or_associate_user(new_user)
    update_attribute(:user, new_user || user || User.create(:name => name, :url => url, :image_url => image_url))
    user
  end

  # Load the appropriate shim class based on the kind of authentication this is
  def service
    @service ||= Service::Base.provider(provider, self)
  end

  # For sorting in users/show.html.haml
  def <=>(other)
    provider <=> other.provider
  end

end