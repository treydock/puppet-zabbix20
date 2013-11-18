require 'spec_helper_system'

describe 'zabbix20::agent::proc class:' do
  context 'should run successfully' do
    pp = <<-EOS
      class { 'zabbix20::agent::proc': }
    EOS

    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end

  describe command('zabbix_agentd -t proc.mem.ext[zabbix_agentd]') do
    it { should return_stdout /\s+\[t\|[0-9]+\]$/ }
    it { should return_exit_status 0 }
  end

  describe command('zabbix_agentd -t proc.cpu.time[zabbix_agentd]') do
    it { should return_stdout /\s+\[t\|[0-9]+\]$/ }
    it { should return_exit_status 0 }
  end
end
