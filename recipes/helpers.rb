chef_gem 'chef-helpers' do
  version node['sanitize']['chef_helpers_version']
  options '--ignore-dependencies'
end
require 'chef-helpers'

include_recipe 'chef-sugar'
