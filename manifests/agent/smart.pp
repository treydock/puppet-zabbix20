# == Class: zabbix20::agent::smart
#
# === Parameters
#
# === Examples
#
#  class { 'zabbix20::agent::smart': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent::smart (
  $manage_sudo    = true,
  $sudo_priority  = 99
) inherits zabbix20::params {

  validate_bool($manage_sudo)

  include zabbix20::agent

  $include_dir  = $zabbix20::agent::include_dir

  if $manage_sudo {
    sudo::conf { 'zabbix_smartctl':
      priority  => $sudo_priority,
      content   => 'zabbix ALL=(ALL) NOPASSWD: /usr/sbin/smartctl -H /dev/sd? , /usr/sbin/smartctl -H /dev/disk/*',
      before    => File['userparameter_smart.conf'],
    }
  }

  file { 'userparameter_smart.conf':
    ensure  => present,
    path    => "${include_dir}/userparameter_smart.conf",
    content => template('zabbix20/agent/userparameter_smart.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$include_dir],
    notify  => Service['zabbix-agent'],
  }

}
