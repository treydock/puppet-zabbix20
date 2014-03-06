require 'spec_helper_acceptance'

describe 'zabbix20::agent::mysql class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'mysql::server': }
        class { 'mysql::server::monitor':
          mysql_monitor_hostname  => 'localhost',
          mysql_monitor_password  => 'secret',
          mysql_monitor_username  => 'zabbix-agent',
        }
        class { 'zabbix20::agent::mysql': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe command('zabbix_agentd --test mysql.ping') do
      it { should return_stdout /^.*\[t\|1\]$/ }
      it { should return_exit_status 0 }
    end
  end
end
