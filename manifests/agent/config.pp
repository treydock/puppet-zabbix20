# == Class: zabbix20::agent::config
#
# === Parameters
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#

class zabbix20::agent::config(
  $pid_file                 = $zabbix20::params::agent_config_hash['pid_file'],
  $log_file                 = $zabbix20::params::agent_config_hash['log_file'],
  $log_file_size            = $zabbix20::params::agent_config_hash['log_file_size'],
  $debug_level              = $zabbix20::params::agent_config_hash['debug_level'],
  $source_ip                = $zabbix20::params::agent_config_hash['source_ip'],
  $enable_remote_commands   = $zabbix20::params::agent_config_hash['enable_remote_commands'],
  $log_remote_commands      = $zabbix20::params::agent_config_hash['log_remote_commands'],
  $server                   = $zabbix20::agent::server,
  $listen_port              = $zabbix20::agent::listen_port,
  $listen_ip                = $zabbix20::params::agent_config_hash['listen_ip'],
  $start_agents             = $zabbix20::params::agent_config_hash['start_agents'],
  $server_active            = $zabbix20::agent::server_active,
  $hostname                 = $zabbix20::params::agent_config_hash['hostname'],
  $hostname_item            = $zabbix20::params::agent_config_hash['hostname_item'],
  $refresh_active_checks    = $zabbix20::params::agent_config_hash['refresh_active_checks'],
  $buffer_send              = $zabbix20::params::agent_config_hash['buffer_send'],
  $buffer_size              = $zabbix20::params::agent_config_hash['buffer_size'],
  $max_lines_per_second     = $zabbix20::params::agent_config_hash['max_lines_per_second'],
  $allow_root               = $zabbix20::params::agent_config_hash['allow_root'],
  $timeout                  = $zabbix20::params::agent_config_hash['timeout'],
  $include                  = $zabbix20::params::agent_config_hash['include'],
  $unsafe_user_parameters   = $zabbix20::params::agent_config_hash['unsafe_user_parameters']
) inherits zabbix20::params {

  include zabbix20::agent

  File <| title == '/etc/zabbix_agentd.conf' |> {
    content => template('zabbix20/zabbix_agentd.conf.erb')
  }

}
