# == Class: zabbix20
#
# === Parameters
#
# === Examples
#
#  class { 'zabbix20': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20 (
  $ensure             = 'present',
  $package_name       = $zabbix20::params::package_name,
  $package_require    = $zabbix20::params::package_require,
  $conf_dir           = $zabbix20::params::conf_dir,
  $log_dir            = $zabbix20::params::log_dir,
  $pid_dir            = $zabbix20::params::pid_dir,
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

  case $::osfamily {
    'RedHat': {
      include epel
    }
    default: {
    }
  }

  $manage_user_real = is_string($manage_user) ? {
    true    => str2bool($manage_user),
    false   => $manage_user,
  }
  validate_bool($manage_user_real)

  $manage_group_real = is_string($manage_group) ? {
    true    => str2bool($manage_group),
    false   => $manage_group,
  }
  validate_bool($manage_group_real)

  $file_require = $manage_group_real ? {
    true  => [ Package['zabbix-agent'], Group['zabbix'] ],
    false => Package['zabbix-agent'],
  }

  case $ensure {
    'present': {
      package { 'zabbix':
        ensure  => 'present',
        name    => $package_name,
        require => $package_require,
      }

      file { '/etc/zabbix':
        ensure    => 'directory',
        path      => $conf_dir,
        owner     => 'root',
        group     => 'root',
        mode      => '0755',
        require   => Package['zabbix'],
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

    'absent': {
      package { 'zabbix':
        ensure  => 'absent',
        name    => $package_name,
      }
    }

    default: {
      # Do nothing
    }
  }

}
