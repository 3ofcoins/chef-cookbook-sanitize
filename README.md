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
* build-essential
* iptables

Attributes
==========

* `sanitize.iptables` -- if false, does not install and configure
  iptables; defaults to true.

* `sanitize.install_packages` -- a list of packages to install on all
  machines; defaults to an empty list.

Usage
=====

Include `recipe[sanitize]` in your run list after your user accounts
are created and sudo and ssh is configured.

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
5. Changes mode of `/var/log/chef/client.log` to `0600` -- readable
   only for root, as it may contain sensitive data
6. Deletes annoying `motd.d` files
7. Installs vim and sets it as a default system editor
8. Installs and configures iptables, opens SSH port (optional, but
   enabled by default)
9. Installs `can-has` command as a symlink to `apt-get`

Roadmap
=======

Plans for future, in no particular order:

* Depend on and include `openssh-server`; configure SSH known hosts,
  provide sane SSH server and client configuration defaults
* Provide hooks (definitions / LWRP / library) for other cookbooks for
  commonly used facilities, such as opening up common ports, "backend"
  http service, SSL keys management, maybe some other "library"
  functions like helpers for encrypted data bags
