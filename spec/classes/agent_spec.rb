require 'spec_helper'

describe 'zabbix20::agent' do

  let :facts do
    {
      :osfamily   => 'RedHat'
    }
  end

  it { should include_class('zabbix20') }
  it { should include_class('zabbix20::params') }
  it { should include_class('zabbix20::agent::firewall')}

  it do
    should contain_package('zabbix20-agent').with({
      'ensure'  => 'present',
      'name'    => 'zabbix20-agent',
    })
  end

  it do
    should contain_service('zabbix-agent').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'name'        => 'zabbix-agent',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[zabbix20-agent]',
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
end
