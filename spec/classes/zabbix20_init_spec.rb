require 'spec_helper'

describe 'zabbix20' do

  let :facts do
    {
      :osfamily   => 'RedHat'
    }
  end

  it { should contain_class('zabbix20::params') }
  it { should include_class('epel') }

  it do
    should contain_package('zabbix').with({
      'ensure'  => 'present',
      'name'    => 'zabbix20',
      'require' => 'Yumrepo[epel]',
    })
  end

  it do
    should contain_file('/etc/zabbix').with({
      'ensure'    => 'directory',
      'path'      => '/etc/zabbix',
      'owner'     => 'root',
      'group'     => 'root',
      'mode'      => '0755',
      'require'   => 'Package[zabbix]',
    })
  end
end
