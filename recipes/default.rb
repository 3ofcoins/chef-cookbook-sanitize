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

include_recipe 'apt'
include_recipe 'chef-client::config'

#
# Delete or disable old system users
# ----------------------------------

#
# Delete default 'ubuntu' user if it exists; it's provided by the EC2 image.

# HACK: Forget about ubuntu user we're about to force delete
Dir.chdir('/root') if Dir.getwd == '/home/ubuntu'
ENV['HOME'] = '/root' if ENV['HOME'] == '/home/ubuntu'
Gem.user_home = '/root' if Gem.user_home == '/home/ubuntu'

user 'ubuntu' do
  action :remove
  supports :manage_home => true
  ignore_failure true
  not_if { node['sanitize']['keep_access'] }
end

#
# Lock out root account - sudo-only. Make sure this runs AFTER your
# users accounts and sudoers file are set up.
user "root" do
  action :lock
  not_if { node['sanitize']['keep_access'] }
end

#
# Sanitize directory structure

directory "/opt"
directory "/srv"
directory Chef::Config[:file_cache_path] do
  recursive true
end

#
# Locale

execute 'locale-gen en_US.UTF-8' do
  not_if do
    cmd = Mixlib::ShellOut.new('locale', '-a')
    cmd.run_command
    cmd.error!
    cmd.stdout.lines.map(&:strip).any? { |ln| ln =~ /^en_US.(?i:utf-?8)$/ }
  end
end

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
  content "Etc/UTC\n"
  notifies :run, "execute[configure time zone]", :immediately
end

#
# Misc

# Update Omnibus Chef client
include_recipe 'omnibus_updater'

# Lock down log that may be created with insufficient permissions
file "/var/log/chef/client.log" do
  mode "0600"
  only_if { File.exists?('/var/log/chef/client.log') }
end

# Why not?
link "/usr/local/bin/can-has" do
  to "/usr/bin/apt-get"
end

# Don't clutter motd.
%w(10-help-text 51_update-motd).each do |fn|
  file "/etc/update-motd.d/#{fn}" do
    action :delete
  end
end

# Vim
package "vim-nox"

execute "update-alternatives --set editor /usr/bin/vim.nox" do
  not_if "update-alternatives --query editor |grep -q '^Value: /usr/bin/vim.nox$'"
end

# Firewall
if node['sanitize']['iptables']
  include_recipe 'iptables'
  iptables_rule "ports_sanitize"
end

# Custom packages
node['sanitize']['apt_repositories'].each do |name, repo|
  distribution_name = if repo['distribution'] == 'lsb_codename'
                        node['lsb']['codename']
                      else
                        repo['distribution']
                      end

  apt_repository name do
    action repo['action'] if repo['action']
    uri repo['uri'] if repo['uri']
    distribution distribution_name if distribution_name
    components repo['components'] if repo['components']
    deb_src repo['deb_src'] if repo['deb_src']
    keyserver repo['keyserver'] if repo['keyserver']
    key repo['key'] if repo['key']
    cookbook repo['cookbook'] if repo['cookbook']
  end
end

node['sanitize']['install_packages'].each do |pkg_name|
  package pkg_name
end
