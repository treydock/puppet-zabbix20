require 'spec_helper'

describe 'zabbix20::agent::smart' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix20::agent::smart') }
  it { should contain_class('zabbix20::params') }
  it { should contain_class('zabbix20::agent') }

  it do
    should contain_sudo__conf('zabbix_smartctl').with({
      'priority'  => '99',
      'content'   => 'zabbix ALL=(ALL) NOPASSWD: /usr/sbin/smartctl -H /dev/*',
      'before'    => 'File[userparameter_smart.conf]',
    })
  end

  it "should create sudoers file" do
    verify_contents(subject, '99_zabbix_smartctl', [
      'zabbix ALL=(ALL) NOPASSWD: /usr/sbin/smartctl -H /dev/*',
    ])
  end

  it do
    should contain_file('userparameter_smart.conf').with({
      'ensure'  =>  'present',
      'path'    => '/etc/zabbix_agentd.conf.d/userparameter_smart.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it "should create UserParameter for smart" do
    verify_contents(subject, 'userparameter_smart.conf', [
      "UserParameter=smartctl.health[*],sudo /usr/sbin/smartctl -H $1 | sed -n -r -e 's/^(SMART overall-health self-assessment test result|SMART Health Status): (.*)$/\\2/p' | grep -c 'OK\\|PASSED'",
    ])
  end

  context 'with sudo_priority => 10' do
    let(:params) {{ :sudo_priority => 10 }}

    it { should contain_sudo__conf('zabbix_smartctl').with_priority('10') }
  end

  context 'with manage_sudo => false' do
    let(:params) {{ :manage_sudo => false }}

    it { should_not contain_sudo__conf('zabbix_smartctl') }
  end
end
