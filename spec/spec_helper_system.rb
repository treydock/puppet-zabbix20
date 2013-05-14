require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

# Override the teardown method to allow for inspectinvg VM
module RSpecSystem
  class NodeSet::Vagrant
    def teardown
       log.info "[Vagrant#teardown] closing all ssh channels"
       RSpec.configuration.ssh_channels.each do |k,v|
         v.close unless v.closed?
       end
  
       if ENV['DESTROY'] =~ /(no|false)/
         log.info "[Vagrant#teardown] SKIPPING 'vagrant destroy'"
       else
         log.info "[Vagrant#teardown] running 'vagrant destroy'"
         vagrant("destroy --force") 
       end
       nil
     end
   end
 end

RSpec.configure do |c|
  # Project root for this module
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  # This is where we 'setup' the nodes before running our tests
  c.system_setup_block = proc do
    # TODO: find a better way of importing this into this namespace
    include RSpecSystemPuppet::Helpers

    # Install puppet
    puppet_install

    # Install module dependencies
    system_run('puppet module install puppetlabs-stdlib --modulepath /etc/puppet/modules')
    
    # Install zabbix20 module
    puppet_module_install(:source => proj_root, :module_name => 'zabbix20')
  end
end