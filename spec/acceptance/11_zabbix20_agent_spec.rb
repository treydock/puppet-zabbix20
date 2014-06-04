require 'spec_helper_acceptance'

describe 'zabbix20::agent class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'zabbix20::agent': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
