require 'spec_helper'

describe 'zabbix20::agent::firewall' do

  let :facts do
    {
      :osfamily   => 'RedHat'
    }
  end

  it { should include_class('zabbix20::agent')}

  it do
    should contain_firewall('100 zabbix-agent').with({
      'ensure'	=> 'present',
      'action'	=> 'accept',
      'port'		=> '10051',
      'chain'		=> 'INPUT',
      'proto'		=> 'tcp',
    })
  end
end
