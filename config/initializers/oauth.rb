OauthProviders = YAML.load_file(Rails.root.join('config', 'oauth.yml'))[Rails.env]

Rails.application.config.middleware.use OmniAuth::Builder do
  OauthProviders.each do |provider_name, creds|
    provider provider_name, creds[:app_id], creds[:app_secret], creds[:options] || {}
  end
end

Twitter.configure do |config|
  config.consumer_key = OauthProviders[:twitter][:app_id]
  config.consumer_secret = OauthProviders[:twitter][:app_secret]
end
