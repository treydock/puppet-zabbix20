# == Class: zabbix20::params
#
# The zabbix20 configuration settings.
#
# === Variables
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix20::params {

  case $::osfamily {
    'RedHat': {
      $package_name                     = 'zabbix20'
      $package_require                  = Yumrepo['epel']
      $agent_package_name               = 'zabbix20-agent'
      $conf_dir                         = '/etc/zabbix'
      $log_dir                          = '/var/log/zabbix'
      $pid_dir                          = '/var/run/zabbix'
      $agent_conf_path                  = '/etc/zabbix_agentd.conf'
      $agent_include_dir                = '/etc/zabbix_agentd.conf.d'
      $agent_logrotate_file             = '/etc/logrotate.d/zabbix-agent'
      $agent_service_name               = 'zabbix-agent'
      $agent_service_has_status         = true
      $agent_service_has_restart        = true
      $agent_log_file_size              = '0'
      $agent_script_dir                 = '/usr/local/bin'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

  $agent_server         = $::zabbix_agent_server ? {
    undef   => '127.0.0.1',
    default => $::zabbix_agent_server,
  }

  $agent_server_active  = $::zabbix_agent_server_active ? {
    undef   => $agent_server,
    default => $::zabbix_agent_server_active
  }

  # Agent - Default configuration values - non-OS specific
  $agent_config_hash                    = {
    'pid_file'                => "${pid_dir}/zabbix_agentd.pid",
    'log_file'                => "${log_dir}/zabbix_agentd.log",
    'log_file_size'           => $agent_log_file_size,
    'debug_level'             => 'UNSET',
    'source_ip'               => 'UNSET',
    'enable_remote_commands'  => 'UNSET',
    'log_remote_commands'     => 'UNSET',
    'listen_ip'               => '0.0.0.0',
    'start_agents'            => 'UNSET',
    'hostname'                => $::fqdn,
    'hostname_item'           => 'UNSET',
    'refresh_active_checks'   => 'UNSET',
    'buffer_send'             => 'UNSET',
    'buffer_size'             => 'UNSET',
    'max_lines_per_second'    => 'UNSET',
    'allow_root'              => 'UNSET',
    'timeout'                 => 'UNSET',
    'include'                 => $agent_include_dir,
    'unsafe_user_parameters'  => 'UNSET',
  }

}