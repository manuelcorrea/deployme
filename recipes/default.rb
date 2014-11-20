#
# Cookbook Name:: deployme
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

user = "ubuntu"

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

git '/home/ubuntu/sinatra_webservices' do
  repository "https://github.com/manuelcorrea/sinatra_webservices.git"
  revision "master"
  action :sync
  ssh_wrapper "/tmp/.ssh/wrap-ssh4git.sh"
  user user
  group user
  notifies :run, "bash[install_app]", :immediately
end

directory '/home/ubuntu/sinatra_webservices/tmp' do
  action :create
  owner user
  group user
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

file "/home/ubuntu/sinatra_webservices/tmp/restart.txt" do
  action  :create
  subscribes :touch, "git[/home/ubuntu/sinatra_webservices]"
  owner user
  group user
end

template "/opt/nginx/sites-available/sinatra_web.conf" do
  source "sinatra_web.conf.erb"
  notifies :restart, "service[nginx]"
end

link "/opt/nginx/sites-enabled/sinatra_web.conf" do
  to "/opt/nginx/sites-available/sinatra_web.conf"
end