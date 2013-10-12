require 'spec_helper'

describe 'zabbix20::agent::nfs' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix20::agent::nfs') }
  it { should contain_class('zabbix20::params') }
  it { should include_class('zabbix20::agent') }

  it do
    should contain_file('userparameter_nfs.conf').with({
      'ensure'  =>  'present',
      'path'    => '/etc/zabbix_agentd.conf.d/userparameter_nfs.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it "should create UserParameter for nfs" do
    verify_contents(subject, 'userparameter_nfs.conf', [
      'UserParameter=nfsd.proc.hung,pgrep nfsd | xargs ps -o state= | egrep -v -c "R|S"',
      'UserParameter=nfsd.threads.count,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f2',
      'UserParameter=nfsd.threads.fullcnt,egrep "^th" /proc/net/rpc/nfsd | cut -d" " -f3',
    ])
  end
end
