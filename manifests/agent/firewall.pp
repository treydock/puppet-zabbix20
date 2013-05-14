# == Class: zabbix20::agent::firewall
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

class zabbix20::agent::firewall (
  $listen_port        = $zabbix20::agent::listen_port
) inherits zabbix20::agent {

  firewall { '100 zabbix-agent':
    ensure  => 'present',
    action  => 'accept',
    port    => $listen_port,
    chain   => 'INPUT',
    proto   => 'tcp',
  }

}
