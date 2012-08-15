require 'securerandom' 

desc "Get everything set up"
task :bootstrap => :environment do
  puts "Creating tables..."

  Rake::Task["db:create"].invoke
  Rake::Task["db:migrate"].invoke
  
  puts "Changing secret token..."

  new_secret = SecureRandom.hex(64)
  config_file_name = Rails.root.join('config', 'initializers', 'secret_token.rb')
  config_file_data = File.read(config_file_name)
  File.open(config_file_name, 'w') do |file|
    file.write(config_file_data.sub('ebbeb491e3c4df723f599c2cdb516530db8d64ccbc5a0d60dc832b8fe90e9fbf3570959c5a545214f4d778d78578ea2a265fc465809b59f79f812d12aed3fea4', new_secret))
  end
  
  puts "All done!"
end
