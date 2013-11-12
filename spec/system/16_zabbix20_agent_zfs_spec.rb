require 'spec_helper_system'

describe 'zabbix20::agent::zfs class:' do
  context 'should run successfully' do
    pp = <<-EOS
      class { 'sudo': purge => false, config_file_replace => false }
      class { 'zabbix20::agent::zfs': }
    EOS

    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end

  describe file('/usr/local/sbin/zfs_trapper.rb') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
  end

  describe cron do
    it { should have_entry('*/5 * * * * /usr/local/sbin/zfs_trapper.rb').with_user('root') }
  end

  describe file('/usr/local/sbin/zpool_trapper.rb') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
  end

  describe cron do
    it { should have_entry('*/5 * * * * /usr/local/sbin/zpool_trapper.rb').with_user('root') }
  end
end
