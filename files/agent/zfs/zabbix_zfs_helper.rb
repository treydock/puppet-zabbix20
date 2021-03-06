#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'logger'
require 'pp'

module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end

module ZFS
  class Util
    def self.is_root?
      Process.uid == 0
    end

    def self.require_sudo?
      ! is_root?
    end
  end

  class Base
    include Logging

    attr_accessor :name, :raw_properties, :sudo, :debug

    def initialize(opts = {})
      @sudo = opts['sudo'] || ZFS::Util.require_sudo?
      @debug = opts['debug'] if opts['debug']
    end

    def name=(val)
      @name = val
      get_raw_properties if @raw_properties.nil?
    end

    def method_missing(m, *args, &block)
      if v = get_property_value(m.to_s)
        v
      else
        super
      end
    end

    private

    def get_property_value(p)
      if @raw_properties[/^#{@name}\s+#{p}\s+([^\s]+)\s+/]
        value = $1
      else
        return
      end

      if value != value.to_i.to_s and !value.is_a? Fixnum
        value
      else
        value.to_i
      end
    end
  end

  class Zpool < Base

    private

    def get_raw_properties
      c = []
      c << "sudo" if @sudo
      c << "zpool get all"
      c << @name
      cmd = c.join(" ")
      logger.debug("Executing: #{cmd}")
      @raw_properties = `#{cmd}`
    end
  end

  class Filesystem < Base
    def total
      available + used unless used.nil? or available.nil?
    end

    def pavailable
      100 * (available.to_f / total.to_f) unless available.nil? or total.nil?
    end

    alias_method :pfree, :pavailable

    def method_missing(m, *args, &block)
      m = "available" if m.to_s.eql?("free")
      super
    end

    private

    def get_raw_properties
      c = []
      c << "sudo" if @sudo
      c << "zfs get -H -p all"
      c << @name
      cmd = c.join(" ")
      logger.debug("Executing: #{cmd}")
      @raw_properties = `#{cmd}`
    end
  end
end

def parse(args)
  mandatory_options = ['key']
  @options = {}
  @options['key'] = nil
  @options['sudo'] = ZFS::Util.require_sudo?
  @options['debug'] = false

  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options] key"

    opts.on('--[no-]sudo', 'Execute commands using sudo') do |s|
      @options['sudo'] = s
    end

    opts.on('--[no-]debug', 'Show debug output') do |d|
      @options['debug'] = d
    end

    opts.on('-h', '--help', 'Display this screen') do
      puts opts
      exit
    end
  end
  
  begin
    optparse.parse!(args)
    @options['key'] = args.first
    mandatory_options.each do |mandatory_option|
      raise OptionParser::MissingArgument, "Missing argument: #{mandatory_option}" if @options[mandatory_option].nil?
    end
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts optparse
    exit
  end

  @options

end

def run!

  include Logging

  @options = parse(ARGV)

  logger.level = @options['debug'] ? Logger::DEBUG : Logger::INFO
  logger.progname = File.basename(__FILE__, ".*")
  logger.formatter = proc do |severtiy, datetime, progname, msg|
    "#{severtiy} -- #{progname}: #{msg}\n"
  end

  logger.debug("Key: #{@options['key']}") if @options['debug']

  if @options['key'] =~ /^(.*)\[(.*)\]$/
    logger.debug("Key match found: #{@options['key']}") if @options['debug']
    key = $1
    logger.debug("Item key: #{key}") if @options['debug']
    args = $2.split(',')
  else
    exit 1
  end

  case key
  when /zfs.fs.size|zfs.property.get/
    @zfs = ZFS::Filesystem.new(@options)
    @zfs.name = args[0]
    puts @zfs.send(args[1])
  when /zpool.property.get/
    @zpool = ZFS::Zpool.new(@options)
    @zpool.name = args[0]
    puts @zpool.send(args[1])
  when /zpool.health/
    @zpool = ZFS::Zpool.new(@options)
    @zpool.name = args[0]
    puts @zpool.send('health')
  end

  exit 0
end

run! if __FILE__==$0
