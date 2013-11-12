require 'spec_helper'

describe 'zabbix20::agent::zfs' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('zabbix20::agent::zfs') }
  it { should contain_class('zabbix20::params') }
  it { should include_class('zabbix20::agent') }

  it do
    should contain_file('zfs_trapper.rb').with({
      'ensure'  => 'present',
      'path'    => '/usr/local/sbin/zfs_trapper.rb',
      'source'  => 'puppet:///modules/zabbix20/zfs/zfs_trapper.rb',
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
      'source'  => 'puppet:///modules/zabbix20/zfs/zpool_trapper.rb',
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

  context "manage_cron => 'false'" do
    let(:params) {{ :manage_cron => 'false' }}
    it { expect { should create_class('zabbix20::agent::zfs') }.to raise_error(Puppet::Error, /is not a boolean/) }
  end
end
