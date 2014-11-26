name "sanitize"
version "0.6.0"

maintainer       "Maciej Pasternacki"
maintainer_email "maciej@pasternacki.net"
license          "MIT"
description      "Sanitizes system by providing a sane default configuration"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

supports 'ubuntu', ">= 10.04"
supports 'mac_os_x'

depends 'apt'
depends 'chef-client'
depends 'dmg'
depends 'homebrew'
depends 'iptables'
depends 'omnibus_updater'
