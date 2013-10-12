# == Class: zabbix20::agent::nfs
#
# === Parameters
#
# === Examples
#
#  class { 'zabbix20::agent::nfs': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent::nfs inherits zabbix20::params {

  include zabbix20::agent

  $include_dir  = $zabbix20::agent::include_dir

  file { 'userparameter_nfs.conf':
    ensure  => present,
    path    => "${include_dir}/userparameter_nfs.conf",
    content => template('zabbix20/agent/userparameter_nfs.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$include_dir],
    notify  => Service['zabbix-agent'],
  }

}
