# frozen_string_literal: true

# Sanitize Chef client's environment

include_recipe 'chef-client::config'
include_recipe 'sanitize::filesystem' # creates `file_cache_path`
