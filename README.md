Description
===========

This cookbook aims to normalize setup of a fresh server and set sane
defaults for global settings, and work with various initial
environments (tested on EC2 images, Hetzner "minimal" installations,
and debootstrap-created LXC images). At the moment it supports only
Ubuntu, Debian support is planned.

This cookbook is developed on GitHub at
https://github.com/3ofcoins/chef-cookbook-sanitize

Requirements
============

* apt
* chef-client
* iptables

Attributes
==========

* `sanitize.iptables` -- if false, does not install and configure
  iptables; defaults to true.

* `sanitize.ip6tables` -- if false, does not install base ip6tables
  rules along with iptables; defaults to true

* `sanitize.keep_access` -- if true, don't disable direct access users
  (ubuntu user or root password); defaults to false.

* `sanitize.ports` -- if `sanitize.iptables` is true, specifies TCP
  ports to open. It is a dictionary, where keys are port numbers or
  service names, and values can be:
  
  * `true` -- open port for any source address
  * `false` -- don't open port
  * a string -- will be used as `--src` argument to `iptables`
  * an array of strings -- for many different `--src` entries
  * **TODO:** It should be possible to specify a node search query

  If the key is a list of ports (`port,port`) or a range
  (`port1:port2`), then the `multiport` iptables module will be used.
  
  If the value is `true` and `sanitize.ip6tables` is `true`, the port
  will be open in ip6tables; ip6tables treats strings as false.

  Default:
  
```ruby
default['sanitize']['ports']['ssh'] = true
```

* `sanitize.accept_interfaces` -- if `sanitize.iptables` is true,
  specifies interfaces to unconditionally accept traffic. It should be
  a dictionary, where key is name of interface, and value should be
  true to accept traffic, or false to not accept (which lets override
  `true` values). Default:
  
```ruby
default['sanitize']['accept_interfaces']['lo'] = true
```

* `sanitize.apt_repositories` -- dictionary of APT repositories to
  add. Key is repository name, value is remaining attributes of the
  `apt_repository` resource provided by the `apt` cookbook (see
  http://community.opscode.com/cookbooks/apt). If you set
  `distribution` to `"lsb_codename"`, `node['lsb']['codename']`
  attribute will be used instead.:

  Ubuntu's PPAs can be specified as a simple string, or as a `ppa`
  key; the second form allows for customizing some of the attributes.

  
```ruby
:sanitize => {
  :apt_repositories => {
    :percona => {
      :uri => 'http://repo.percona.com/apt',
      :distribution => 'lsb_codename',
      :components => [ 'main' ],
      :deb_src => true,
      :keyserver => 'hkp://keys.gnupg.net',
      :key => '1C4CBDCDCD2EFD2A'
    },
    :ruby_ng => 'ppa:brightbox/ruby-ng',
    :nginx => {
      :ppa => 'nginx/stable',
      :distribution => 'precise' # force distribution regardless of lsb.codename
    }
    }}
```

* `sanitize.install_packages` -- a list of packages to install on all
  machines; defaults to an empty list.

* `sanitize.locale.default="en_US.UTF-8"`,
  `sanitize.locale.available=[]` -- list of locales to make available
  on the server, and a locale to set as default.

Usage
=====

Include `recipe[sanitize]` in your run list after your user accounts
are created and sudo and ssh is configured, and otherwise as early as
possible. In particular, if you use `omnibus_updater` cookbook, it
should be after `sanitize` in the run list.

sanitize::default
-----------------

This is the default "base settings" setup. It should be called
**after** shell user accounts and sudo are configured, as it locks
default login user and direct root access.

1. Deletes `ubuntu` system user
2. Locks system password for `root` user (assumes that only sudo is
   used to elevate privileges)
3. Ensure all FHS-provided directories exist by creating some that
   have been found missing on some of the installation (namely,
   `/opt`)
4. Sets locale to `en_US.UTF-8`, generates this locale, sets time zone
   to UTC
5. Deletes annoying `motd.d` files
6. Installs vim and sets it as a default system editor
7. Installs and configures iptables, opens SSH port (optional, but
   enabled by default)
8. Installs `can-has` command as a symlink to `apt-get`
9. Runs `chef-client::config`

Roadmap
=======

Plans for future, in no particular order:

* Depend on and include `openssh-server`; configure SSH known hosts,
  provide sane SSH server and client configuration defaults
* Provide hooks (definitions / LWRP / library) for other cookbooks for
  commonly used facilities, such as opening up common ports, "backend"
  http service, SSL keys management, maybe some other "library"
  functions like helpers for encrypted data bags
* Test with test-kitchen
