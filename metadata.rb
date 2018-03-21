# frozen_string_literal: true

name 'sanitize'
version '1.0.1'

maintainer       'Maciej Pasternacki'
maintainer_email 'maciej@pasternacki.net'
license          'MIT'
description      'Sanitizes system by providing a sane default configuration'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/3ofcoins/chef-cookbook-sanitize'
issues_url 'https://github.com/3ofcoins/chef-cookbook-sanitize/issues'

supports 'ubuntu', '>= 14.04'
chef_version '>= 12.14'

depends 'apt'
depends 'chef-client'
depends 'iptables'
