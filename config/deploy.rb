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

rake_cmd = fetch(:rake)

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
  
  after "deploy:update" do
    run "cd #{base_dir} #{rake_cmd} assets:precompile"
  end
end
