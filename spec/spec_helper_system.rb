require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'
require 'rspec-system-serverspec/helpers'

include RSpecSystemPuppet::Helpers
include Serverspec::Helper::RSpecSystem
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  # Project root for the this module's code
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Fixture root for this module's code
  fixtures_root = File.expand_path(File.join(proj_root, 'spec', 'fixtures'))

  # Enable colour in Jenkins
  c.tty = true

  c.include RSpecSystemPuppet::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    # Install puppet
    puppet_install
    puppet_master_install

    # Install module dependencies
    shell('puppet module install puppetlabs/mysql --modulepath /etc/puppet/modules --force --version ">=0.6.0 <1.0.0"')
    shell('puppet module install puppetlabs/stdlib --modulepath /etc/puppet/modules --force')
    shell('puppet module install stahnma/epel --modulepath /etc/puppet/modules --force')
    shell('puppet module install puppetlabs/firewall --modulepath /etc/puppet/modules --force')
    shell('puppet module install saz/sudo --modulepath /etc/puppet/modules --force --version ">=2.0.0"')
    
    # Install zabbix20 module
    puppet_module_install(:source => proj_root, :module_name => 'zabbix20')
  end
end
