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
  $manage_cron = true,
  $zfs_trapper_minute = '*/5',
  $zfs_trapper_hour = 'absent',
  $zpool_trapper_minute = '*/5',
  $zpool_trapper_hour = 'absent',
) inherits zabbix20::params {

  validate_bool($manage_cron)

  include zabbix20::agent

  file { 'zfs_trapper.rb':
    ensure  => present,
    path    => "${scripts_dir}/zfs_trapper.rb",
    source  => 'puppet:///modules/zabbix20/zfs/zfs_trapper.rb',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => Cron['zfs_trapper.rb'],
  }

  file { 'zpool_trapper.rb':
    ensure  => present,
    path    => "${scripts_dir}/zpool_trapper.rb",
    source  => 'puppet:///modules/zabbix20/zfs/zpool_trapper.rb',
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
