require 'beaker-rspec'

module SystemHelper
  def proj_root
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def modulefile_dependencies
    dependencies = []
    modulefile = File.join(proj_root, "Modulefile")

    return false unless File.exists?(modulefile)

    File.open(modulefile).each do |line|
      if line =~ /^dependency\s+(.*)/
        dependency = {}
        m = $1.split(',')
        fullname = m[0].tr("'|\"", "")
        dependency[:fullname] = fullname
        dependency[:name] = fullname.split("/").last
        dependency[:version] = m[1].tr("'|\"", "").strip
        dependencies << dependency
      else
        next
      end
    end

    dependencies
  end
end

include SystemHelper

hosts.each do |host|
  #install_puppet
  if host['platform'] =~ /el-(5|6)/
    relver = $1
    on host, "rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-#{relver}.noarch.rpm", { :acceptable_exit_codes => [0,1] }
    on host, 'yum install -y puppet-3.5.1-1.el6', { :acceptable_exit_codes => [0,1] }
  end
end

RSpec.configure do |c|
  c.include SystemHelper

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Install module
      copy_root_module_to(host, :module_name => 'zabbix20')

      # Install module dependencies
      modulefile_dependencies.each do |mod|
        on host, puppet("module", "install", "#{mod[:fullname]}", "--version",  "'#{mod[:version]}'"), { :acceptable_exit_codes => [0,1] }
      end
    end
  end
end