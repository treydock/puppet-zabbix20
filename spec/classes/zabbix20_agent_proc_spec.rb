require 'spec_helper'

describe 'zabbix20::agent::proc' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix20::agent::proc') }
  it { should contain_class('zabbix20::params') }
  it { should contain_class('zabbix20::agent') }

  it do
    should contain_file('userparameter_proc.conf').with({
      'ensure'  =>  'present',
      'path'    => '/etc/zabbix_agentd.conf.d/userparameter_proc.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it do
    content = catalogue.resource('file', 'userparameter_proc.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=proc.mem.ext[*],echo "$(pgrep $([ -z "$2" ] && echo "" || echo "-u $2") $([ -z "$4" ] && echo "" || echo "-f $4") $([ -z "$1" ] && echo "" || echo $1) | xargs ps -orss= | paste -sd+ | bc) * 1024"|bc',
      'UserParameter=proc.cpu.time[*],pgrep $([ -z "$2" ] && echo "" || echo "-u $2") $([ -z "$4" ] && echo "" || echo "-f $4") $([ -z "$1" ] && echo "" || echo $1) | xargs ps -ocputime= | awk \'{ split($$1,t,"[:-]"); $$2=t[4]*3600*24+t[3]*3600+t[2]*60+t[1]; print $$2;}\' | paste -sd+ | bc',
    ]
  end
end
