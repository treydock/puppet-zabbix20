# == Class: zabbix20::agent::mysql
#
# === Parameters
#
# === Examples
#
#  class { 'zabbix20::agent::mysql': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent::mysql (
  $mysql_monitor_hostname = 'UNSET',
  $mysql_monitor_password = 'UNSET',
  $mysql_monitor_username = 'UNSET'
) inherits zabbix20::params {

  include zabbix20
  include zabbix20::agent
  include mysql::server::monitor

  $manage_user  = $zabbix20::manage_user
  $user_name    = $zabbix20::user_name
  $user_home    = $zabbix20::user_home
  $group_name   = $zabbix20::group_name
  $include_dir  = $zabbix20::agent::include_dir

  $mysql_monitor_hostname_real = $mysql_monitor_hostname ? {
    'UNSET' => $mysql::server::monitor::mysql_monitor_hostname,
    default => $mysql_monitor_hostname,
  }
  $mysql_monitor_password_real = $mysql_monitor_password ? {
    'UNSET' => $mysql::server::monitor::mysql_monitor_password,
    default => $mysql_monitor_password,
  }
  $mysql_monitor_username_real = $mysql_monitor_username ? {
    'UNSET' => $mysql::server::monitor::mysql_monitor_username,
    default => $mysql_monitor_username,
  }

  $my_cnf_require = $manage_user ? {
      true  => User['zabbix'],
      false => Package['zabbix-agent'],
    }

  file { "${include_dir}/userparameter_mysql.conf":
    ensure  => present,
    content => template('zabbix20/agent/userparameter_mysql.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$include_dir],
    notify  => Service['zabbix-agent'],
  }

  file { "${user_home}/.my.cnf":
    ensure  => present,
    content => template('zabbix20/agent/my.cnf.erb'),
    owner   => $user_name,
    group   => $group_name,
    mode    => '0600',
    require => $my_cnf_require,
  }

}
