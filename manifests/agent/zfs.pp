# == Class: zabbix20::agent::zfs
#
# === Parameters
#
# === Examples
#
#  class { 'zabbix20::agent::zfs': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent::zfs (
  $scripts_dir = '/usr/local/sbin',
  $manage_sudo = true,
  $manage_cron = true,
  $sudo_commands = $zabbix20::params::zfs_sudo_commands,
  $sudo_priority = 10,
  $zfs_trapper_minute = '*/5',
  $zfs_trapper_hour = 'absent',
  $zpool_trapper_minute = '*/5',
  $zpool_trapper_hour = 'absent'
) inherits zabbix20::params {

  validate_bool($manage_sudo)
  validate_bool($manage_cron)

  include zabbix20::agent

  $include_dir  = $zabbix20::agent::include_dir
  $user_name    = $zabbix20::agent::user_name

  $file_require = $manage_sudo ? {
    true  => [ Sudo::Conf['zabbix_zfs'], File[$include_dir] ],
    false => File[$include_dir],
  }

  $sudo_commands_real = is_string($sudo_commands) ? {
    true  => $sudo_commands,
    false => join($sudo_commands, ','),
  }

  if $manage_sudo {
    sudo::conf { 'zabbix_zfs':
      priority  => $sudo_priority,
      content   => template('zabbix20/agent/zfs.sudoers.erb'),
    }
  }

  file { 'userparameter_zfs.conf':
    ensure  => present,
    path    => "${include_dir}/userparameter_zfs.conf",
    content => template('zabbix20/agent/userparameter_zfs.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => $file_require,
    notify  => Service['zabbix-agent'],
  }

  file { 'arcstat_get.py':
    ensure  => present,
    path    => "${scripts_dir}/arcstat_get.py",
    source  => 'puppet:///modules/zabbix20/agent/zfs/arcstat_get.py',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => File['userparameter_zfs.conf'],
  }

  file { 'zabbix_zfs_helper.rb':
    ensure  => present,
    path    => "${scripts_dir}/zabbix_zfs_helper.rb",
    source  => 'puppet:///modules/zabbix20/agent/zfs/zabbix_zfs_helper.rb',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => File['userparameter_zfs.conf'],
  }

  file { 'zfs_trapper.rb':
    ensure  => present,
    path    => "${scripts_dir}/zfs_trapper.rb",
    source  => 'puppet:///modules/zabbix20/agent/zfs/zfs_trapper.rb',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => Cron['zfs_trapper.rb'],
  }

  file { 'zpool_trapper.rb':
    ensure  => present,
    path    => "${scripts_dir}/zpool_trapper.rb",
    source  => 'puppet:///modules/zabbix20/agent/zfs/zpool_trapper.rb',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => Cron['zpool_trapper.rb'],
  }

  if $manage_cron {
    cron { 'zfs_trapper.rb':
      ensure    => present,
      command   => "${scripts_dir}/zfs_trapper.rb",
      user      => 'root',
      hour      => $zfs_trapper_hour,
      minute    => $zfs_trapper_minute,
      month     => absent,
      monthday  => absent,
      weekday   => absent,
    }

    cron { 'zpool_trapper.rb':
      ensure    => present,
      command   => "${scripts_dir}/zpool_trapper.rb",
      user      => 'root',
      hour      => $zpool_trapper_hour,
      minute    => $zpool_trapper_minute,
      month     => absent,
      monthday  => absent,
      weekday   => absent,
    }
  }
}
