name "sanitize"
version "1.0.0"

maintainer       "Maciej Pasternacki"
maintainer_email "maciej@pasternacki.net"
license          "MIT"
description      "Sanitizes system by providing a sane default configuration"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

supports 'ubuntu', ">= 14.04"

depends 'apt'
depends 'chef-client'
depends 'dmg'
depends 'homebrew'
depends 'iptables'
