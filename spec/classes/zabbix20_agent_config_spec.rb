require 'spec_helper'

shared_context 'zabbix20::agent::config' do

  let :facts do
    {
      :osfamily   => 'RedHat'
    }
  end

  it { should contain_class('zabbix20::agent') }

  it do
    should contain_file('/etc/zabbix_agentd.conf').with({
      'ensure'  => 'present',
      'path'    => '/etc/zabbix_agentd.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[zabbix20-agent]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it do
    should contain_file('/etc/zabbix_agentd.conf') \
      .with_content(/^PidFile=\/var\/run\/zabbix\/zabbix_agentd.pid$/)
  end

end
