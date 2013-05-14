require 'spec_helper'

describe 'zabbix20' do

  let :facts do
    {
      :osfamily   => 'RedHat'
    }
  end

  it { should include_class('zabbix20::params') }

  it do
    should contain_package('zabbix20').with({
      'ensure'  => 'present',
      'name'    => 'zabbix20',
    })
  end

  it do
    should contain_file('/etc/zabbix').with({
      'ensure'    => 'directory',
      'path'      => '/etc/zabbix',
      'owner'     => 'root',
      'group'     => 'root',
      'mode'      => '0755',
      'require'   => 'Package[zabbix20]',
    })
  end
end
