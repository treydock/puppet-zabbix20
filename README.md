# puppet-zabbix20 [![Build Status](https://travis-ci.org/treydock/puppet-zabbix20.png)](https://travis-ci.org/treydock/puppet-zabbix20)

Puppet module to manage Zabbix 2.0.x installations

This module currently only manages Zabbix Agents.

## Support

Tested using

* CentOS 6.4
* Scientific Linux 6.4
* CentOS 5.9 (Vagrant tested only)

## Usage

Install and configure a Zabbix Agent

    class { 'zabbix::agent': }

## Development

### Dependencies

* rake
* bundler

### Unit testing

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake ci


### Vagrant system tests

If you have Vagrant >= 1.1.0 installed you can run system tests

    bundle exec rake spec:system

## TODO

* Manage Zabbix Server
* Manage Zabbix Proxy
