require 'spec_helper'

describe 'zabbix20::agent' do

  let :facts do
    {
      :osfamily   => 'RedHat'
    }
  end

  let :constant_parameter_defaults do
    {
      :service_ensure   => 'running',
      :service_enable   => 'true',
      :manage_firewall  => 'true',
      :listen_port      => '10051',
    }
  end

  let :params do
    constant_parameter_defaults
  end

  it { should include_class('zabbix20') }
  it { should include_class('zabbix20::params') }
  it { should include_class('zabbix20::agent::firewall') }
  it { should contain_class('zabbix20::agent::config') }

  it do
    should contain_package('zabbix20-agent').with({
      'ensure'  => 'present',
      'name'    => 'zabbix20-agent',
    })
  end

  it do
    should contain_service('zabbix-agent').with({
      'ensure'      => params[:service_ensure],
      'enable'      => params[:service_enable],
      'name'        => 'zabbix-agent',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[zabbix20-agent]',
    })
  end
  
  it do
    should contain_file('/etc/zabbix/zabbix_agentd.conf.d').with({
      'ensure'  => 'directory',
      'path'    => '/etc/zabbix/zabbix_agentd.conf.d',
      'owner'   => 'root',
      'group'   => 'zabbix',
      'mode'    => '0775',
      'require' => 'File[/etc/zabbix]',
    })
  end

  it do
    should contain_file('/var/run/zabbix').with({
      'ensure'    => 'directory',
      'path'      => '/var/run/zabbix',
      'owner'     => 'root',
      'group'     => 'zabbix',
      'mode'      => '0775',
      'require'   => ['Package[zabbix20-agent]', 'Group[zabbix]'],
    })
  end

  it do
    should contain_file('/var/log/zabbix').with({
      'ensure'    => 'directory',
      'path'      => '/var/log/zabbix',
      'owner'     => 'root',
      'group'     => 'zabbix',
      'mode'      => '0775',
      'require'   => ['Package[zabbix20-agent]', 'Group[zabbix]'],
    })
  end

  it do
    should contain_user('zabbix').with({
      'ensure'     => 'present',
      'name'       => 'zabbix',
      'home'       => '/var/lib/zabbix',
      'shell'      => '/sbin/nologin',
      'gid'        => 'zabbix',
      'system'     => 'true',
      'comment'    => 'Zabbix Monitoring System',
      'managehome' => 'true',
    })
  end

  it do
    should contain_group('zabbix').with({
      'ensure'  => 'present',
      'name'    => 'zabbix',
      'system'  => 'true',
    })
  end

  describe 'zabbix20::agent::config' do
    include_context 'zabbix20::agent::config'
  end

  describe 'zabbix20::agent::firewall' do
    include_context 'zabbix20::agent::firewall'
  end
end
