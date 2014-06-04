require 'spec_helper_acceptance'

describe 'zabbix20::agent::vfs class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'zabbix20::agent::vfs': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end