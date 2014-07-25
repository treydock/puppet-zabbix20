# == Class: zabbix20::agent::vfs
#
class zabbix20::agent::vfs inherits zabbix20::params {

  include zabbix20::agent

  $include_dir  = $zabbix20::agent::include_dir

  if $zabbix20::agent::ensure == 'present' {
    file { 'userparameter_vfs.conf':
      ensure  => present,
      path    => "${include_dir}/userparameter_vfs.conf",
      content => template('zabbix20/agent/userparameter_vfs.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File[$include_dir],
      notify  => Service['zabbix-agent'],
    }
  }

}
