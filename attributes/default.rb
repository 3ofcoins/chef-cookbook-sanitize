# frozen_string_literal: true

default['sanitize']['iptables'] = true
default['sanitize']['ip6tables'] = true
default['sanitize']['keep_access'] = false
default['sanitize']['install_packages'] = []
default['sanitize']['packages'] = {}
default['sanitize']['apt_repositories'] = {}
default['sanitize']['ports']['ssh'] = true
default['sanitize']['accept_interfaces']['lo'] = true
default['sanitize']['locale']['default'] = 'en_US.UTF-8'
default['sanitize']['locale']['available'] = []
