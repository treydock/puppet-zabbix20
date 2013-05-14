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
      $agent_package_name               = 'zabbix20-agent'
      $conf_dir                         = '/etc/zabbix'
      $log_dir                          = '/var/log/zabbix'
      $pid_dir                          = '/var/run/zabbix'
      $agent_service_name               = 'zabbix-agent'
      $agent_service_has_status         = true
      $agent_service_has_restart        = true
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}