# == Class: zabbix20::agent::proc
#
# === Examples
#
#  class { 'zabbix20::agent::proc': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent::proc inherits zabbix20::params {

  include zabbix20::agent

  $include_dir  = $zabbix20::agent::include_dir

  file { 'userparameter_proc.conf':
    ensure  => present,
    path    => "${include_dir}/userparameter_proc.conf",
    content => template('zabbix20/agent/userparameter_proc.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$include_dir],
    notify  => Service['zabbix-agent'],
  }

}
