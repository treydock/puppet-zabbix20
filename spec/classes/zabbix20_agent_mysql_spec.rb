require 'spec_helper'

describe 'zabbix20::agent::mysql' do
  include_context :defaults

  let(:facts){ default_facts }

  let :pre_condition do
    [
      "class { 'mysql::server': }",
      "class { 'mysql::server::monitor':
        mysql_monitor_hostname  => 'localhost',
        mysql_monitor_password  => 'secret',
        mysql_monitor_username  => 'zabbix-agent',
      }",
    ]
  end

  it { should contain_class('zabbix20::params') }
  it { should contain_class('zabbix20') }
  it { should contain_class('zabbix20::agent') }
  it { should contain_class('mysql::server::monitor') }

  it do
    should contain_file('/etc/zabbix_agentd.conf.d/userparameter_mysql.conf').with({
      'ensure'  =>  'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it "/etc/zabbix_agentd.conf.d/userparameter_mysql.conf should have valid content" do
    verify_contents(catalogue, '/etc/zabbix_agentd.conf.d/userparameter_mysql.conf', [
      'UserParameter=mysql.ping,HOME=/var/lib/zabbix mysqladmin ping | grep alive | wc -l',
      'UserParameter=mysql.uptime,HOME=/var/lib/zabbix mysqladmin status | cut -f2 -d":" | cut -f1 -d"T"',
      'UserParameter=mysql.threads,HOME=/var/lib/zabbix mysqladmin status | cut -f3 -d":" | cut -f1 -d"Q"',
      'UserParameter=mysql.questions,HOME=/var/lib/zabbix mysqladmin status | cut -f4 -d":" | cut -f1 -d"S"',
      'UserParameter=mysql.slowqueries,HOME=/var/lib/zabbix mysqladmin status | cut -f5 -d":" | cut -f1 -d"O"',
      'UserParameter=mysql.qps,HOME=/var/lib/zabbix mysqladmin status | cut -f9 -d":"',
      'UserParameter=mysql.version,mysql -V',
      'UserParameter=mysql.slave.running,HOME=/var/lib/zabbix mysql -s -r -N -e "SHOW GLOBAL STATUS like \'slave_running\'" | cut -f2',
      'UserParameter=mysql.slave.iorunning,HOME=/var/lib/zabbix mysql -e "SHOW SLAVE STATUS\G" | sed -r -e \'s/^\s+Slave_IO_Running: (.*)$/\1/g;tx;d;:x\'',
      'UserParameter=mysql.slave.sqlrunning,HOME=/var/lib/zabbix mysql -e "SHOW SLAVE STATUS\G" | sed -r -e \'s/^\s+Slave_SQL_Running: (.*)$/\1/g;tx;d;:x\'',
      'UserParameter=mysql.slave.secondsbehindmaster,HOME=/var/lib/zabbix mysql -e "SHOW SLAVE STATUS\G" | sed -r -e \'s/^\s+Seconds_Behind_Master: (.*)$/\1/g;tx;d;:x\'',
    ])
  end

  it do
    should contain_file('/var/lib/zabbix/.my.cnf').with({
      'ensure'    => 'present',
      'owner'     => 'zabbix',
      'group'     => 'zabbix',
      'mode'      => '0600',
      'require'   => 'User[zabbix]',
    })
  end

  it "/var/lib/zabbix/.my.cnf should have valid content" do
    verify_contents(catalogue, '/var/lib/zabbix/.my.cnf', [
      'host=localhost',
      'user=zabbix-agent',
      'password=secret',
    ])
  end

  context 'when manage_user => false' do
    let :pre_condition do
      [
        "class { 'mysql::server': }",
        "class { 'mysql::server::monitor':
          mysql_monitor_hostname  => 'localhost',
          mysql_monitor_password  => 'secret',
          mysql_monitor_username  => 'zabbix-agent',
        }",
        "class { 'zabbix20': manage_user => false }",
      ]
    end

    it { should contain_file('/var/lib/zabbix/.my.cnf').with_require('Package[zabbix-agent]') }
  end

  context 'when zabbix20::agent::ensure => absent' do
    let(:pre_condition) { "class { 'zabbix20::agent': ensure => 'absent' }" }
    it { should_not contain_class('mysql::server::monitor') }
    it { should_not contain_file('/etc/zabbix_agentd.conf.d/userparameter_mysql.conf') }
    it { should_not contain_file('/var/lib/zabbix/.my.cnf') }
  end

end
