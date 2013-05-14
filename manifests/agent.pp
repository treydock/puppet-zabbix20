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
  $listen_port        = '10051',
  $config_hash        = $zabbix20::params::agent_config_hash
) inherits zabbix20 {

  include zabbix20::params

  $manage_firewall_real = is_string($manage_firewall) ? {
    true    => str2bool($manage_firewall),
    false   => $manage_firewall,
  }
  validate_bool($manage_firewall_real)

  if $manage_firewall_real {
    include zabbix20::agent::firewall
  }

  Class['zabbix20::agent'] -> Class['zabbix20::agent::config']

  $config_class = { 'zabbix20::agent::config' => $config_hash }

  create_resources( 'class', $config_class )

  package { 'zabbix20-agent':
    ensure  => 'present',
    name    => $zabbix20::params::agent_package_name,
  }

  service { 'zabbix-agent':
    ensure      => $service_ensure,
    enable      => $service_enable,
    name        => $zabbix20::params::agent_service_name,
    hasstatus   => $zabbix20::params::agent_service_has_status,
    hasrestart  => $zabbix20::params::agent_service_has_restart,
    require     => Package['zabbix20-agent'],
  }

  file { '/etc/zabbix/zabbix_agentd.conf.d':
    ensure  => 'directory',
    path    => $zabbix20::params::agent_include_dir,
    owner   => 'root',
    group   => $zabbix20::group_name,
    mode    => '0775',
    require => File['/etc/zabbix'],
  }

  @file { '/etc/zabbix_agentd.conf':
    ensure  => 'present',
    path    => $zabbix20::params::agent_conf_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['zabbix20-agent'],
    notify  => Service['zabbix-agent'],
  }

  File <| title == '/var/run/zabbix' |>

  File <| title == '/var/log/zabbix' |>

  if $zabbix20::manage_user_real {
    User <| title == 'zabbix' |>
  }

  if $zabbix20::manage_group_real {
    Group <| title == 'zabbix' |>
  }

}
