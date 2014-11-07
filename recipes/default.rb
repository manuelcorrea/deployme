#
# Cookbook Name:: deployme
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

user = "vagrant"

package 'git'

directory "/tmp/.ssh" do
  owner user
  recursive true
end

cookbook_file "/tmp/.ssh/wrap-ssh4git.sh" do
  source "wrap-ssh4git.sh"
  owner user
  mode '0700'
end


deploy "/home/ubuntu/sinatra_webservices" do
  repo "https://github.com/manuelcorrea/sinatra_webservices.git"
  revision "master"
  user user
  environment "RAILS_ENV" => "production"
  keep_releases 10
  action :deploy
  restart_command "touch tmp/restart.txt"
  git_ssh_wrapper "/tmp/.ssh/wrap-ssh4git.sh"
  notifies :restart, "service[foo]"
end

bash "install_app" do
  user user
  code <<-EOH
    cd /home/ubuntu/sinatra_webservices
    source /usr/local/rvm/scripts/rvm
    rvm use 2.1.1
    gem install bundler
    bundle install --deployment
  EOH
end

template "/opt/nginx/sites-available/sinatra_web.conf" do
  source "sinatra_web.conf.erb"
  notifies :restart, "service[nginx]"
end

link "/opt/nginx/sites-enabled/sinatra_web.conf" do
  to "/opt/nginx/sites-available/sinatra_web.conf"
end