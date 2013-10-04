#!/usr/bin/env ruby

require 'rubygems'
require 'json'

MDSTAT_PATH = ARGV[0].nil? ? '/proc/mdstat' : ARGV[0]

module Mdraid
  module Stat
    @@mdstat_path  = '/proc/mdstat'

    def self.list(path = @@mdstat_path)
      @mdstat = read_mdstat(path)
      @devices = []

      @mdstat.each_line do |line|
        params = line.split(' ')
        next unless params[0] =~ /md\d+/
        @devices << {
          :name => params[0],
          :status => params[2],
          :level => params[3],
          :devices => params[4..-1]
        }
      end
      @devices
    end

    def self.zabbix_list(path = @@mdstat_path)
      @mdstat = read_mdstat(path)
      @devices = {}
      @devices[:data] = []

      @mdstat.each_line do |line|
        params = line.split(' ')
        next unless params[0] =~ /md\d+/
        data = {
          "{#MD_DEVICE}" => params[0],
          "{#STATUS}" => params[2],
          "{#LEVEL}" => params[3],
        }
        @devices[:data] << data
      end
      JSON.parse(@devices.to_json)
    end

    private

    def self.read_mdstat(path)
      output = ""
      begin
        mdstat_file  = File.open(path)
        output       += mdstat_file.read_nonblock(1024) while true
      rescue EOFError
        # Expected
      rescue
        return nil
      ensure
        mdstat_file.close if mdstat_file
      end

      output
    end
  end
end

jj Mdraid::Stat.zabbix_list(MDSTAT_PATH)
