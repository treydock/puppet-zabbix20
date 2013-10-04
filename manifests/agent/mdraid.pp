# == Class: zabbix20::agent::mdraid
#
# === Parameters
#
# === Examples
#
#  class { 'zabbix20::agent::mdraid': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent::mdraid inherits zabbix20::params {

  include zabbix20::agent

  $script_dir   = $zabbix20::params::agent_script_dir
  $include_dir  = $zabbix20::agent::include_dir

  file { 'userparameter_mdraid.conf':
    ensure  => present,
    path    => "${include_dir}/userparameter_mdraid.conf",
    content => template('zabbix20/agent/userparameter_mdraid.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$include_dir],
    notify  => Service['zabbix-agent'],
  }

  file { 'vfs_md_discovery.rb':
    ensure  => present,
    path    => "${script_dir}/vfs_md_discovery.rb",
    source  => 'puppet:///modules/zabbix20/vfs_md_discovery.rb',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => File['userparameter_mdraid.conf'],
  }

}
