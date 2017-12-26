require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/rvm'
require 'mina/puma'

set :user, 'ubuntu'
set :domain, 'ec2-18-218-29-136.us-east-2.compute.amazonaws.com'
set :deploy_to, '/var/www/amist'
set :repository, 'https://github.com/justinbee/amist.git'
set :branch, 'master'
set :identity_file, '/Users/justin/.ssh/riding-ruby-rails.pem'

set :term_mode, :system
set :puma_socket, "/home/ubuntu/amist.sock"
set :app_path, lambda { "#{deploy_to}/#{current_path}" }

set :keep_releases, 8

set :shared_paths, ['tmp/pids', 'log']


task :environment do
  invoke :'rbenv:load'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]  

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]   
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    #invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    invoke :'deploy:cleanup'
    
    to :launch do
      invoke :restart
    end
  end
end

desc 'Starts the application'
task :start => :environment do
  invoke :'puma:start'
end

desc 'Stops the application'
task :stop => :environment do
  invoke :'puma:stop'
end

desc 'Restarts the application'
task :restart => :environment do
  invoke :'puma:restart'
end

