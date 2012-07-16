set :application, "Simplifeed"

default_run_options[:pty] = true  # Must be set for the password prompt from git to work

set :scm, :git
set :scm_username, 'dfmcphee'
set :scm_verbose, true
set :git_shallow_clone, 1
set :repository, "git@bitbucket.org:#{scm_username}/simplifeed.git"
set :branch, "master"

set :use_sudo, false
set :deploy_to, '/var/www/simplifeed'
set :base_dir, '/var/www/simplifeed/current'
set :user, 'dom'
set :password, 'TheOnly1'

server "199.192.229.170", :app, :web, :db, :primary => true


namespace :deploy do
  task :start do
  end

  task :stop do
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  task :restart, :roles => :web do
    run "touch /var/www/simplifeed/current/tmp/restart.txt"
  end
  
  task :precompile, :roles => :web, :except => { :no_release => true } do
          from = source.next_revision(current_revision)
          run "cd #{latest_release} && rake assets:precompile"
   end
end

# Manual Tasks
  
namespace :db do

  desc "Syncs the database.yml file from the local machine to the remote machine"
  task :sync_yaml do
    puts "\n\n=== Syncing database yaml to the production server! ===\n\n"
    unless File.exist?("config/database.yml")
      puts "There is no config/database.yml.\n "
      exit
    end
    system "rsync -vr --exclude='.DS_Store' config/database.yml #{user}@#{application}:#{shared_path}/config/"
  end
  
  desc "Create Production Database"
  task :create do
    puts "\n\n=== Creating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:create RAILS_ENV=production"
    system "cap deploy:set_permissions"
  end

  desc "Migrate Production Database"
  task :migrate do
    puts "\n\n=== Migrating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
  end

  desc "Resets the Production Database"
  task :migrate_reset do
    puts "\n\n=== Resetting the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:migrate:reset RAILS_ENV=production"
  end
  
  desc "Destroys Production Database"
  task :drop do
    puts "\n\n=== Destroying the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:drop RAILS_ENV=production"
    system "cap deploy:set_permissions"
  end

  desc "Moves the SQLite3 Production Database to the shared path"
  task :move_to_shared do
    puts "\n\n=== Moving the SQLite3 Production Database to the shared path! ===\n\n"
    run "mv #{current_path}/db/production.sqlite3 #{shared_path}/db/production.sqlite3"
    system "cap deploy:setup_symlinks"
    system "cap deploy:set_permissions"
  end

  desc "Populates the Production Database"
  task :seed do
    puts "\n\n=== Populating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end

end