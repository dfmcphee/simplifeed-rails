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
set :user, ''
set :password, ''

rake_cmd = fetch(:rake)

server "", :app, :web, :db, :primary => true


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
  
  task :precompile, :roles => :web do
    run "cd #{base_dir} RAILS_ENV=production #{rake_cmd} assets:precompile"
  end
end
