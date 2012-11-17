#
# Cookbook Name:: sanitize
# Recipe:: default
#
# Copyright 2012, Maciej Pasternacki
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

## Prerequisites and system information

require 'etc'

node['build_essential']['compiletime'] = true

include_recipe 'apt'
include_recipe 'build-essential'

## Delete default 'ubuntu' user if it exists; it's provided by the EC2 image.

ubuntu_user = begin
                Etc.getpwnam('ubuntu')
              rescue ArgumentError
                nil
              end

# HACK: Forget about ubuntu user we're about to force delete
Dir.chdir('/root') if Dir.getwd == '/home/ubuntu'
ENV['HOME'] = '/root' if ENV['HOME'] == '/home/ubuntu'
Gem.user_home = '/root' if Gem.user_home == '/home/ubuntu'

# FIXME: use 'user' resource?
execute "userdel -r -f ubuntu || true" do
  only_if { ubuntu_user }
end

## Lock out root account - sudo-only. Make sure this runs AFTER your
## users accounts and sudoers file are set up.

chef_gem "ruby-shadow"

user "root" do
  password '!*'
end

## Sanitize directory structure

directory "/opt"

## Locale

execute 'locale-gen en_US.UTF-8'

file '/etc/default/locale' do
  content 'LANG=en_US.UTF-8'
  owner 'root'
  group 'root'
  mode '0644'
end

execute "configure time zone" do
  action :nothing
  command "dpkg-reconfigure -fnoninteractive tzdata"
end

file '/etc/timezone' do
  content 'Etc/UTC'
  notifies :run, "execute[configure time zone]", :immediately
end

## Misc

file "/var/log/chef/client.log" do
  mode "0600"
end

link "/usr/local/bin/can-has" do
  to "/usr/bin/apt-get"
end

%w(10-help-text 51_update-motd).each do |fn|
  file "/etc/update-motd.d/#{fn}" do
    action :delete
  end
end

package "vim-nox"

execute "update-alternatives --set editor /usr/bin/vim.nox" do
  not_if "update-alternatives --query editor |grep -q '^Value: /usr/bin/vim.nox$'"
end

if node['sanitize']['iptables']
  include_recipe 'iptables'
  iptables_rule "port_ssh"
end

node['sanitize']['install_packages'].each do |pkg_name|
  package pkg_name
end
