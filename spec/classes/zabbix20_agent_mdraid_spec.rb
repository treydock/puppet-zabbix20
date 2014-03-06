require 'spec_helper'

describe 'zabbix20::agent::mdraid' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix20::agent::mdraid') }
  it { should contain_class('zabbix20::params') }
  it { should contain_class('zabbix20::agent') }

  it do
    should contain_file('userparameter_mdraid.conf').with({
      'ensure'  =>  'present',
      'path'    => '/etc/zabbix_agentd.conf.d/userparameter_mdraid.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it "should create UserParameter for mdraid" do
    verify_contents(catalogue, 'userparameter_mdraid.conf', [
      'UserParameter=vfs.md.degraded[*],cat /sys/block/$1/md/degraded',
      'UserParameter=vfs.md.discovery,/var/lib/zabbix/bin/vfs_md_discovery.rb',
    ])
  end

  it do
    should contain_file('/usr/local/bin/vfs_md_discovery.rb').with({
      'ensure'    => 'absent',
    })
  end

  it do
    should contain_file('vfs_md_discovery.rb').with({
      'ensure'    => 'present',
      'path'      => '/var/lib/zabbix/bin/vfs_md_discovery.rb',
      'source'    => 'puppet:///modules/zabbix20/vfs_md_discovery.rb',
      'owner'     => 'zabbix',
      'group'     => 'zabbix',
      'mode'      => '0755',
      'before'    => 'File[userparameter_mdraid.conf]',
    })
  end
end
