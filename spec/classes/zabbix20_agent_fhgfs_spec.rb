require 'spec_helper'

describe 'zabbix20::agent::fhgfs' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix20::agent::fhgfs') }
  it { should contain_class('zabbix20::params') }
  it { should contain_class('zabbix20::agent') }

  it do
    should contain_file('userparameter_fhgfs.conf').with({
      'ensure'  =>  'present',
      'path'    => '/etc/zabbix_agentd.conf.d/userparameter_fhgfs.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'require' => 'File[/etc/zabbix_agentd.conf.d]',
      'notify'  => 'Service[zabbix-agent]',
    })
  end

  it "should create UserParameter for fhgfs" do
    content = catalogue.resource('file', 'userparameter_fhgfs.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=fhgfs.client.status,test -f /proc/fs/fhgfs/*/.status && echo "1" || echo "0"',
      'UserParameter=fhgfs.list_unreachable,fhgfs-check-servers | grep UNREACHABLE | sed -r -e \'s/^(.*)\s+\[.*\]:\s+UNREACHABLE/\1/g\' | paste -sd ","',
      'UserParameter=fhgfs.management.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=management | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.metadata.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=metadata | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.storage.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=storage | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.client.reachable[*],fhgfs-ctl --listnodes --reachable --nodetype=client | grep -A1 \'^$1 \[\' | grep -c "Reachable: <yes>"',
      'UserParameter=fhgfs.pool.status[*],fhgfs-ctl --listpools --nodetype=$2 | sed -r -n -e \'s|^\s+$1+\s+\[(.*)\]$|\1|p\'',
      'UserParameter=fhgfs.client.num,fhgfs-ctl --listnodes --nodetype=client | wc -l',
      'UserParameter=fhgfs.metadata.iostat[*],/var/lib/zabbix/bin/metadata_iostat.sh $1 $2 $3',
      'UserParameter=fhgfs.storage.iostat[*],/var/lib/zabbix/bin/storage_iostat.sh $1 $2 $3',
    ]
  end

  it do
    should contain_file('metadata_iostat.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/metadata_iostat.sh",
      'source'  => 'puppet:///modules/zabbix20/agent/fhgfs/metadata_iostat.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'File[userparameter_fhgfs.conf]',
    })
  end

  it do
    should contain_file('storage_iostat.sh').with({
      'ensure'  => 'present',
      'path'    => "/var/lib/zabbix/bin/storage_iostat.sh",
      'source'  => 'puppet:///modules/zabbix20/agent/fhgfs/storage_iostat.sh',
      'owner'   => 'zabbix',
      'group'   => 'zabbix',
      'mode'    => '0755',
      'before'  => 'File[userparameter_fhgfs.conf]',
    })
  end
end
