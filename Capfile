# first, give capistrano the name of the app.
load 'deploy' if respond_to?(:namespace) # cap2 differentiator
 
set :application, "blog" # App name.
set :domain,      "kubrick.nickcharlton.net" # App domain.
set :deploy_to,   "/var/www/apps/#{application}" # Directory to deploy to.

# what to deploy
set :scm, :git
set :repository, "git@github.com:nickcharlton/nickcharlton.net.git" # Where to get it via git.
set :branch, "master"

# Here we use the server keyword to build a command of where to deploy to.
# 'domain' is assigned above, and we deploy to this, using the rest of the string.
# The rest tells us to deploy the app to our web server 
# (in this case, all our servers are the same)
server domain, :web, :app
 
# Specific to Rails Machine
# Settings to use to connect to the remote server
# not modified for Kubrick/Zefridge (Nick, you should check this).
set :app_server, :passenger
set :user, "nickcharlton"
set :runner, user
set :admin_runner, user
default_run_options[:pty] = true
 
# What to do after deploying. (Specific to Passenger).
namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end