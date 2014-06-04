require 'spec_helper_acceptance'

describe 'zabbix20::agent::zfs class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'sudo': purge => false, config_file_replace => false }
        class { 'zabbix20::agent::zfs': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/sudoers.d/10_zabbix_zfs') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 440 }
    end

    describe file('/etc/zabbix_agentd.conf.d/userparameter_zfs.conf') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 644 }
    end

    describe file('/usr/local/sbin/arcstat_get.py') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 755 }
    end

    describe file('/usr/local/sbin/zabbix_zfs_helper.rb') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 755 }
    end

    describe file('/usr/local/sbin/zabbix_zfs_trapper.rb') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 755 }
    end

    describe cron do
      it { should have_entry('*/5 * * * * /usr/local/sbin/zabbix_zfs_trapper.rb').with_user('root') }
    end
  end
end
