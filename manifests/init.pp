# == Class: zabbix20
#
# Full description of class zabbix20 here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { zabbix20: }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class zabbix20 (
  $package_name       = $zabbix::params::package_name,
  $conf_dir           = $zabbix::params::conf_dir,
  $log_dir            = $zabbix::params::log_dir,
  $pid_dir            = $zabbix::params::pid_dir,
  $manage_user        = true,
  $manage_group       = true,
  $user_name          = 'zabbix',
  $user_uid           = undef,
  $user_home          = '/var/lib/zabbix',
  $user_shell         = '/sbin/nologin',
  $user_comment       = 'Zabbix Monitoring System',
  $group_name         = 'zabbix',
  $group_gid          = undef
) inherits zabbix20::params {

  # TODO : CONVERT STR2BOOL HERE
  $manage_group_real = is_string($manage_group) ? {
    true    => str2bool($manage_group),
    false   => $manage_group,
  }

  $file_require = $manage_group_real ? {
    true  => [ Package['zabbix-agent'], Group['zabbix'] ],
    false => Package['zabbix-agent'],
  }

  package { 'zabbix20':
    ensure  => 'present',
    name    => $package_name,
  }

  file { '/etc/zabbix':
    ensure    => 'directory',
    path      => $conf_dir,
    owner     => 'root',
    group     => 'root',
    mode      => '0755',
    require   => Package['zabbix20'],
  }

  @file { '/var/run/zabbix':
    ensure    => 'directory',
    path      => $pid_dir,
    owner     => 'root',
    group     => $group_name,
    mode      => '0775',
    require   => $file_require,
  }

  @file { '/var/log/zabbix':
    ensure    => 'directory',
    path      => $log_dir,
    owner     => 'root',
    group     => $group_name,
    mode      => '0775',
    require   => $file_require,
  }

  @user { 'zabbix':
    ensure     => 'present',
    name       => $user_name,
    home       => $user_home,
    shell      => $user_shell,
    gid        => $group_name,
    system     => true,
    comment    => $user_comment,
    managehome => true,
  }

  @group { 'zabbix':
    ensure  => 'present',
    name    => $group_name,
    system  => true,
  }

}
