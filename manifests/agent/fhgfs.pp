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
  $script_dir   = $zabbix20::agent::script_dir
  $user_name    = $zabbix20::agent::user_name
  $group_name   = $zabbix20::agent::group_name

  $metadata_iostat_path = "${script_dir}/metadata_iostat.sh"
  $storage_iostat_path  = "${script_dir}/storage_iostat.sh"

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

  file { 'metadata_iostat.sh':
    ensure  => present,
    path    => $metadata_iostat_path,
    source  => 'puppet:///modules/zabbix20/agent/fhgfs/metadata_iostat.sh',
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    before  => File['userparameter_fhgfs.conf'],
  }

  file { 'storage_iostat.sh':
    ensure  => present,
    path    => $storage_iostat_path,
    source  => 'puppet:///modules/zabbix20/agent/fhgfs/storage_iostat.sh',
    owner   => $user_name,
    group   => $group_name,
    mode    => '0755',
    before  => File['userparameter_fhgfs.conf'],
  }
}
