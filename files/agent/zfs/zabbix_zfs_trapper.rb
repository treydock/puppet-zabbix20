#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'optparse'
require 'logger'
require 'pp'
require 'zabbix_zfs_helper'

def parse(args)
  @options = {}
  @options['name'] = "tank"
  @options['hostname'] = `hostname -f`.strip
  @options['server'] = IO.read('/etc/zabbix_agentd.conf').scan(/^Server=(.*)$/).flatten.first.split(',').first

  optparse = OptionParser.new do |opts|
    
    opts.on('--name', 'name of zfs filesystem to monitor') do |name|
      @options['name'] = name
    end

    opts.on('--hostname', 'hostname in Zabbix') do |hostname|
      @options['hostname'] = hostname
    end

    opts.on('--server', 'Zabbix Server to send trapper data') do |server|
      @options['server'] = server
    end

    opts.on('-h', '--help', 'Display this screen') do
      puts opts
      exit
    end
  end
  
  begin
    optparse.parse!(args)
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts optparse
    exit
  end

  @options

end

include Logging

@options = parse(ARGV)

logger.level = Logger::INFO
logger.datetime_format = "%Y-%m-%d %H:%M:%S"
logger.formatter = proc do |severtiy, datetime, progname, msg|
  "#{datetime.strftime(logger.datetime_format)}: #{msg}\n"
end

ZABBIX_SEND_DATAFILE = "/tmp/#{File.basename(__FILE__, '.*')}.txt"
ZFS_KEY_NAME = 'zfs.trapper.get'
ZFS_GET = [
  'available',
  'used',
  'total',
  'pavailable',
]

ZPOOL_KEY_NAME = 'zpool.trapper.get'
ZPOOL_GET = [
  'health'
]

@zfs = ZFS::Filesystem.new
@zfs.name = @options['name']

@zpool = ZFS::Zpool.new
@zpool.name = @options['name']

@time = Time.now.to_i

results = []
ZFS_GET.each do |key|
  results << "#{@options['hostname']} #{ZFS_KEY_NAME}[#{key},#{@zfs.name}] #{@time} #{@zfs.send(key)}\n"
end

ZPOOL_GET.each do |key|
  results << "#{@options['hostname']} #{ZPOOL_KEY_NAME}[#{key},#{@zpool.name}] #{@time} #{@zpool.send(key)}\n"
end

File.open(ZABBIX_SEND_DATAFILE, "w") { |f| f.write(results) }

logger.info("Zabbix send datafile:\n#{File.read(ZABBIX_SEND_DATAFILE)}")

sender_cmd = "zabbix_sender -z #{@options['server']} -p 10051 -T -i #{ZABBIX_SEND_DATAFILE}"
logger.info("Executing: #{sender_cmd}")
sender_output = `#{sender_cmd}`
exit_status = $?.to_s
logger.info("Zabbix sender output:\n#{sender_output}")
logger.info("Exit code: #{exit_status}")

exit 0
