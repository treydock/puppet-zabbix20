require 'spec_helper'

describe 'zabbix20::agent::vfs' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix20::agent::vfs') }
  it { should contain_class('zabbix20::params') }
  it { should contain_class('zabbix20::agent') }

  it do
    should contain_file('userparameter_vfs.conf').with({
      'ensure'  =>  'present',
      'path'    => '/etc/zabbix_agentd.conf.d/userparameter_vfs.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it "should create UserParameter for vfs" do
    verify_contents(catalogue, 'userparameter_vfs.conf', [
      'UserParameter=vfs.fs.mounted[*],mountpoint -q $1 && echo 1 || echo 0',
    ])
  end

  context 'when zabbix20::agent::ensure => absent' do
    let(:pre_condition) { "class { 'zabbix20::agent': ensure => 'absent' }" }
    it { should_not contain_file('userparameter_vfs.conf') }
  end
end
