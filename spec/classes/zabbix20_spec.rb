require 'spec_helper'

describe 'zabbix20' do

  let :facts do
    RSpec.configuration.default_facts.merge({

    })
  end

  it { should contain_class('zabbix20::params') }

end
