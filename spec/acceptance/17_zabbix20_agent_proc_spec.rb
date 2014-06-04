require 'spec_helper_acceptance'

describe 'zabbix20::agent::proc class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'zabbix20::agent::proc': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
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
end
