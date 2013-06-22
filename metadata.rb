maintainer       "Maciej Pasternacki"
maintainer_email "maciej@pasternacki.net"
license          "MIT"
description      "Sanitizes system by providing a sane default configuration"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"

supports 'ubuntu', ">= 10.04"

depends 'apt'
depends 'build-essential'
depends 'iptables'
