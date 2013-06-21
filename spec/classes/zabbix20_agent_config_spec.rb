require 'spec_helper'

shared_context 'zabbix20::agent::config' do
  describe 'zabbix20::agent::config' do
    it { should include_class('zabbix20::agent') }

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
        .with_content(/^PidFile=\/var\/run\/zabbix\/zabbix_agentd.pid$/) \
        .with_content(/^LogFile=\/var\/log\/zabbix\/zabbix_agentd.log$/) \
        .with_content(/^ListenPort=10050$/) \
        .with_content(/^ListenIP=0.0.0.0$/) \
        .with_content(/^Hostname=#{node}$/) \
        .with_content(/^Include=\/etc\/zabbix_agentd.conf.d$/)
    end
  end
end
