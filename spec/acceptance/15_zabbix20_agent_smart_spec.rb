require 'spec_helper_acceptance'

describe 'zabbix20::agent::smart class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'sudo': purge => false, config_file_replace => false }
        class { 'zabbix20::agent::smart': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end