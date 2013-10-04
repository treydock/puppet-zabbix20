shared_examples_for 'zabbix20::agent::config' do
  it { should include_class('zabbix20::agent') }

  it do
    should contain_file('/etc/zabbix_agentd.conf').with({
      'ensure'  => 'present',
      'path'    => '/etc/zabbix_agentd.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[zabbix-agent]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it do
    verify_contents(subject, '/etc/zabbix_agentd.conf', [
      'PidFile=/var/run/zabbix/zabbix_agentd.pid',
      'LogFile=/var/log/zabbix/zabbix_agentd.log',
      'ListenPort=10050',
      'ListenIP=0.0.0.0',
      "Hostname=#{node}",
      'Include=/etc/zabbix_agentd.conf.d',
    ])
  end
end
