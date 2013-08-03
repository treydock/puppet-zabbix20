require 'spec_helper_system'

describe 'zabbix20::agent::mysql class:' do
  context 'should run successfully' do
    pp = <<-EOS
      class { 'mysql::server': }
      class { 'mysql::server::monitor':
        mysql_monitor_hostname  => 'localhost',
        mysql_monitor_password  => 'secret',
        mysql_monitor_username  => 'zabbix-agent',
      }
      class { 'zabbix20::agent::mysql': }
    EOS

    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end

    context shell('zabbix_agentd --test mysql.ping') do
      its(:stdout) { should =~ /^.*\[t\|1\]$/ }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
