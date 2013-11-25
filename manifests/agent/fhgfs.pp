# == Class: zabbix20::agent::fhgfs
#
# === Examples
#
#  class { 'zabbix20::agent::fhgfs': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent::fhgfs inherits zabbix20::params {

  include zabbix20::agent

  $include_dir  = $zabbix20::agent::include_dir

  file { 'userparameter_fhgfs.conf':
    ensure  => present,
    path    => "${include_dir}/userparameter_fhgfs.conf",
    content => template('zabbix20/agent/userparameter_fhgfs.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$include_dir],
    notify  => Service['zabbix-agent'],
  }
}
