require 'spec_helper'

describe 'zabbix20::agent' do
  include_context :defaults

  let(:facts){ default_facts }

  let(:node) { 'foo.example.com' }

  let :constant_parameter_defaults do
    {
      :service_ensure   => 'running',
      :service_enable   => 'true',
      :manage_firewall  => 'true',
      :with_logrotate   => 'true',
      :listen_port      => '10050',
    }
  end

  let :params do
    constant_parameter_defaults
  end

  it { should contain_class('zabbix20::params') }
  it { should contain_class('zabbix20') }
  it { should contain_class('zabbix20::agent::config') }

  it do
    should contain_firewall('100 zabbix-agent').with({
      'ensure'	=> 'present',
      'action'	=> 'accept',
      'port'		=> params[:listen_port],
      'chain'		=> 'INPUT',
      'proto'		=> 'tcp',
    })
  end

  it do
    should contain_file('/etc/logrotate.d/zabbix-agent').with({
      'ensure'  =>  'present',
      'path'    => '/etc/logrotate.d/zabbix-agent',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'Package[zabbix-agent]',
    }) \
      .with_content(/^\/var\/log\/zabbix\/zabbix_agentd.log\s+\{$/) \
      .with_content(/^\s+create 0664 zabbix zabbix$/)
  end

  it do
    should contain_package('zabbix-agent').with({
      'ensure'  => 'present',
      'name'    => 'zabbix20-agent',
      'require' => 'Yumrepo[epel]',
    })
  end

  it do
    should contain_service('zabbix-agent').with({
      'ensure'      => params[:service_ensure],
      'enable'      => params[:service_enable],
      'name'        => 'zabbix-agent',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[zabbix-agent]',
    })
  end
  
  it do
    should contain_file('/etc/zabbix_agentd.conf.d').with({
      'ensure'  => 'directory',
      'path'    => '/etc/zabbix_agentd.conf.d',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
    })
  end

  it do
    should contain_file('/var/run/zabbix').with({
      'ensure'    => 'directory',
      'path'      => '/var/run/zabbix',
      'owner'     => 'root',
      'group'     => 'zabbix',
      'mode'      => '0775',
      'require'   => ['Package[zabbix-agent]', 'Group[zabbix]'],
    })
  end

  it do
    should contain_file('/var/log/zabbix').with({
      'ensure'    => 'directory',
      'path'      => '/var/log/zabbix',
      'owner'     => 'root',
      'group'     => 'zabbix',
      'mode'      => '0775',
      'require'   => ['Package[zabbix-agent]', 'Group[zabbix]'],
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

  it do
    should contain_file('zabbix-agent-script-dir').with({
      'ensure'    => 'directory',
      'path'      => '/var/lib/zabbix/bin',
      'owner'     => 'zabbix',
      'group'     => 'zabbix',
      'mode'      => '0750',
      'require'   => 'User[zabbix]',
    })
  end

  context 'when manage_user => false' do
    let(:pre_condition) { "class { 'zabbix20': manage_user => false }" }
    it { should contain_file('zabbix-agent-script-dir').with_require('Package[zabbix-agent]') }
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should_not contain_firewall('100 zabbix-agent') }
    it { should_not contain_file('/etc/logrotate.d/zabbix-agent') }
    it { should contain_package('zabbix-agent').with_ensure('absent') }
    it { should contain_service('zabbix-agent').with_ensure('stopped') }
    it { should contain_service('zabbix-agent').with_enable('false') }
    it { should_not contain_file('/etc/zabbix_agentd.conf.d') }
    it { should_not contain_file('/var/run/zabbix') }
    it { should_not contain_file('/var/log/zabbix') }
    it { should_not contain_user('zabbix') }
    it { should_not contain_group('zabbix') }
    it { should_not contain_file('zabbix-agent-script-dir') }
  end

  it_behaves_like 'zabbix20::agent::config'
end
