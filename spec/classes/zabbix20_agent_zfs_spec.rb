require 'spec_helper'

describe 'zabbix20::agent::zfs' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('zabbix20::agent::zfs') }
  it { should contain_class('zabbix20::params') }
  it { should include_class('zabbix20::agent') }

  it { should contain_sudo__conf('zabbix_zfs').with_priority('10') }

  it "create sudoers.d file 10_zabbix_zfs" do
    content = subject.resource('file', '10_zabbix_zfs').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'Defaults:zabbix !requiretty',
      'Cmnd_Alias ZFS_CMDS = /sbin/zpool status *,/sbin/zpool list *,/sbin/zfs list *,/sbin/zfs get *',
      'Runas_Alias ZFS_USER = root',
      'zabbix ALL=(ZFS_USER) NOPASSWD: ZFS_CMDS',
    ]
  end

  it do
    should contain_file('userparameter_zfs.conf').with({
      'ensure'  =>  'present',
      'path'    => '/etc/zabbix_agentd.conf.d/userparameter_zfs.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => ['Sudo::Conf[zabbix_zfs]', 'File[/etc/zabbix_agentd.conf.d]'],
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it "should create userparameter_zfs.conf" do
    content = subject.resource('file', 'userparameter_zfs.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=zpool.health[*],sudo /sbin/zpool list -H -o health $1',
      'UserParameter=zfs.get[*],echo `sudo /sbin/zfs get -H -p $1 $2` | tr -s \' \' | cut -d \' \' -f 3',
      'UserParameter=zfs.arcstat[*],grep "^$1 " /proc/spl/kstat/zfs/arcstats | awk -F" " \'{ print $$3 }\'',
      'UserParameter=zfs.arcstat.get[*],/usr/local/sbin/arcstat_get.py $1',
    ]
  end

  it do
    should contain_file('arcstat_get.py').with({
      'ensure'  => 'present',
      'path'    => '/usr/local/sbin/arcstat_get.py',
      'source'  => 'puppet:///modules/zabbix20/agent/zfs/arcstat_get.py',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'before'  => 'File[userparameter_zfs.conf]',
    })
  end

  it do
    should contain_file('zfs_trapper.rb').with({
      'ensure'  => 'present',
      'path'    => '/usr/local/sbin/zfs_trapper.rb',
      'source'  => 'puppet:///modules/zabbix20/agent/zfs/zfs_trapper.rb',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'before'  => 'Cron[zfs_trapper.rb]',
    })
  end

  it do
    should contain_cron('zfs_trapper.rb').with({
      'ensure'    => 'present',
      'command'   => "/usr/local/sbin/zfs_trapper.rb",
      'user'      => 'root',
      'hour'      => 'absent',
      'minute'    => '*/5',
      'month'     => 'absent',
      'monthday'  => 'absent',
      'weekday'   => 'absent',
    })
  end

  it do
    should contain_file('zpool_trapper.rb').with({
      'ensure'  => 'present',
      'path'    => '/usr/local/sbin/zpool_trapper.rb',
      'source'  => 'puppet:///modules/zabbix20/agent/zfs/zpool_trapper.rb',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
      'before'  => 'Cron[zpool_trapper.rb]',
    })
  end

  it do
    should contain_cron('zpool_trapper.rb').with({
      'ensure'    => 'present',
      'command'   => "/usr/local/sbin/zpool_trapper.rb",
      'user'      => 'root',
      'hour'      => 'absent',
      'minute'    => '*/5',
      'month'     => 'absent',
      'monthday'  => 'absent',
      'weekday'   => 'absent',
    })
  end

  context "manage_sudo => false" do
    let(:params) {{ :manage_sudo => false }}
    it { should_not contain_sudo__conf('zabbix_zfs') }
    it { should_not contain_file('10_zabbix_zfs') }
    it { should contain_file('userparameter_zfs.conf').with_require('File[/etc/zabbix_agentd.conf.d]') }
  end

  context "sudo_commands => '/sbin/zpool status *,/sbin/zpool list *,/sbin/zfs list *,/sbin/zfs get *'" do
    let(:params) {{ :sudo_commands => '/sbin/zpool status *,/sbin/zpool list *,/sbin/zfs list *,/sbin/zfs get *' }}
    it do
      content = subject.resource('file', '10_zabbix_zfs').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'Defaults:zabbix !requiretty',
        'Cmnd_Alias ZFS_CMDS = /sbin/zpool status *,/sbin/zpool list *,/sbin/zfs list *,/sbin/zfs get *',
        'Runas_Alias ZFS_USER = root',
        'zabbix ALL=(ZFS_USER) NOPASSWD: ZFS_CMDS',
      ]
    end
  end

  context "sudo_priority => 20" do
    let(:params) {{ :sudo_priority => 20 }}
    it { should contain_sudo__conf('zabbix_zfs').with_priority('20') }
    it { should contain_file('20_zabbix_zfs') }
  end

  context "manage_cron => false" do
    let(:params) {{ :manage_cron => false }}
    it { should_not contain_cron('zfs_trapper.rb') }
    it { should_not contain_cron('zpool_trapper.rb') }
  end

  context "zfs_trapper_minute => '*/10'" do
    let(:params) {{ :zfs_trapper_minute => '*/10' }}
    it { should contain_cron('zfs_trapper.rb').with_minute('*/10') }
  end

  context "zpool_trapper_minute => '*/10'" do
    let(:params) {{ :zpool_trapper_minute => '*/10' }}
    it { should contain_cron('zpool_trapper.rb').with_minute('*/10') }
  end

  context "scripts_dir => '/opt/sbin'" do
    let(:params){{ :scripts_dir => '/opt/sbin' }}
    it { should contain_file('zfs_trapper.rb').with_path('/opt/sbin/zfs_trapper.rb') }
    it { should contain_file('zpool_trapper.rb').with_path('/opt/sbin/zpool_trapper.rb') }
  end


  [
    'manage_sudo',
    'manage_cron',
  ].each do |bool_param|
    context "with #{bool_param} => 'foo'" do
      let(:params) {{ bool_param.to_sym => 'foo' }}
      it { expect { should create_class('zabbix20::agent::zfs') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end