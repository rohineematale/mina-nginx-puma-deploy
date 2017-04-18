#config/deploy.rb

require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/bundler'
require 'mina/puma'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :term_mode, nil
set :application_name, 'my_app'
set :domain, 'xxxxxxx'
set :deploy_to, '/var/app/my_app'
set :repository, 'git@github.com:xxx/my_app.git'
set :branch, 'master'
set :rails_env, ENV['to'].nil? ? 'staging' : ENV['to']

# Optional settings:
  set :user, 'ubuntu'          # Username in the server to SSH to.
  set :port, '22'           # SSH port number.
  set :forward_agent, true     # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/pids', 'tmp/sockets')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')
# set :shared_dirs, fetch(:shared_dirs, []).push('somedir')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', '<ruby-version>@my_app'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %{mkdir -p "/var/app/my_app/shared/log"}
  command %{chmod g+rx,u+rwx "/var/app/my_app/shared/log"}

  command %{mkdir -p "/var/app/my_app/shared/config"}
  command %{chmod g+rx,u+rwx "/var/app/my_app/shared/config"}

  command %{touch "/var/app/my_app/shared/config/database.yml"}
  command %{echo "-----> Be sure to edit '/var/app/my_app/shared/config/database.yml'."}
  
  command %{touch "/var/app/my_app/shared/config/secrets.yml"}
  command %{echo "-----> Be sure to edit '/var/app/my_app/shared/config/secrets.yml'."}
  # command %{rbenv install 2.3.0}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
      end
      invoke :'puma:restart'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

namespace :nginx do
  desc "Start the WebServer"
  task :start do
    command 'echo "-----> Start Nginx"'
    command "service nginx start"
  end

  desc "Stop the WebServer"
  task :stop do
    command 'echo "-----> Stop Nginx"'
    command "service nginx stop"
  end

  desc "Restart the WebServer"
  task :restart do
    command 'echo "-----> Restart Nginx"'
    command "service nginx restart"
  end

  desc "Show error logs"
  task :logs do
    command 'tail -f /var/log/nginx/error.log'
  end
end


namespace :puma do
  desc "Start the application"
  task :start do
    command 'echo "-----> Start Puma"'
    command "cd /var/app/my_app/current && RAILS_ENV=#{ENV['to']} && bin/puma.sh start", :pty => false
  end

  desc "Stop the application"
  task :stop do
    command 'echo "-----> Stop Puma"'
    command "cd /var/app/my_app/current && RAILS_ENV=#{ENV['to']} && bin/puma.sh stop"
  end

  desc "Restart the application"
  task :restart do
    command 'echo "-----> Restart Puma"'
    command "cd /var/app/my_app/current && RAILS_ENV=#{ENV['to']} && bin/puma.sh restart"
  end
end
# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs