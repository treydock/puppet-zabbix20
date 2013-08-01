# == Class: zabbix20::agent
#
# === Parameters
#
# === Examples
#
#  class { 'zabbix20::agent': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::agent (
  $server             = $zabbix20::params::agent_server,
  $server_active      = $zabbix20::params::agent_server_active,
  $service_ensure     = 'running',
  $service_enable     = true,
  $manage_firewall    = true,
  $with_logrotate     = true,
  $listen_port        = '10050',
  $config_hash        = $zabbix20::params::agent_config_hash
) inherits zabbix20::params {

  include zabbix20

  $package_name         = $zabbix20::params::agent_package_name
  $service_name         = $zabbix20::params::agent_service_name
  $service_has_status   = $zabbix20::params::agent_service_has_status
  $service_has_restart  = $zabbix20::params::agent_service_has_restart
  $include_dir          = $zabbix20::params::agent_include_dir
  $conf_path            = $zabbix20::params::agent_conf_path
  $logrotate_file       = $zabbix20::params::agent_logrotate_file

  $package_require      = $zabbix20::package_require
  $user_name            = $zabbix20::user_name
  $group_name           = $zabbix20::group_name
  $manage_user          = $zabbix20::manage_user_real
  $manage_group         = $zabbix20::manage_group_real

  $manage_firewall_real = is_string($manage_firewall) ? {
    true    => str2bool($manage_firewall),
    false   => $manage_firewall,
  }
  validate_bool($manage_firewall_real)

  $with_logrotate_real = is_string($with_logrotate) ? {
    true    => str2bool($with_logrotate),
    false   => $with_logrotate,
  }
  validate_bool($with_logrotate_real)

  if $manage_firewall_real {
    firewall { '100 zabbix-agent':
      ensure  => 'present',
      action  => 'accept',
      port    => $listen_port,
      chain   => 'INPUT',
      proto   => 'tcp',
    }
  }

  if $with_logrotate_real {
    file { '/etc/logrotate.d/zabbix-agent':
      ensure  => present,
      path    => $logrotate_file,
      content => template('zabbix20/zabbix-agent.logrotate.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['zabbix-agent'],
    }
  }

  Class['zabbix20::agent'] -> Class['zabbix20::agent::config']

  $config_class = { 'zabbix20::agent::config' => $config_hash }

  create_resources( 'class', $config_class )

  package { 'zabbix-agent':
    ensure  => 'present',
    name    => $package_name,
    require => $package_require,
  }

  service { 'zabbix-agent':
    ensure      => $service_ensure,
    enable      => $service_enable,
    name        => $service_name,
    hasstatus   => $service_has_status,
    hasrestart  => $service_has_restart,
    require     => Package['zabbix-agent'],
  }

  file { '/etc/zabbix_agentd.conf.d':
    ensure  => 'directory',
    path    => $include_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  @file { '/etc/zabbix_agentd.conf':
    ensure  => 'present',
    path    => $conf_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['zabbix-agent'],
    notify  => Service['zabbix-agent'],
  }

  File <| title == '/var/run/zabbix' |>

  File <| title == '/var/log/zabbix' |>

  if $manage_user {
    User <| title == 'zabbix' |>
  }

  if $manage_group {
    Group <| title == 'zabbix' |>
  }

}
