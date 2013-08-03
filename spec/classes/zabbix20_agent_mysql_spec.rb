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
  it { should include_class('zabbix20') }
  it { should include_class('zabbix20::agent') }
  it { should include_class('mysql::server::monitor') }

  it do
    should contain_file('/etc/zabbix_agentd.conf.d/userparameter_mysql.conf').with({
      'ensure'  =>  'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    }) \
      .with_content(/^UserParameter=mysql.ping,HOME=\/var\/lib\/zabbix mysqladmin ping | grep alive | wc -l$/)
  end

  it do
    should contain_file('/var/lib/zabbix/.my.cnf').with({
      'ensure'    => 'present',
      'owner'     => 'zabbix',
      'group'     => 'zabbix',
      'mode'      => '0600',
      'require'   => 'User[zabbix]',
    }) \
      .with_content(/^host=localhost$/) \
      .with_content(/^user=zabbix-agent$/) \
      .with_content(/^password=secret$/)
  end
end
