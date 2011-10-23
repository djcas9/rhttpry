require 'eventmachine'
require 'msgpack'
require 'optparse'
require 'pathname'
require 'ipaddr'

require 'sinatra/base'

require 'httpry/collect'
require 'httpry/agent'
require 'httpry/ui'

#
module Httpry
  
  #
  class CLI
    
    attr_accessor :options

    def initialize(args)
      @args = args
      @options = {
        :collect => false,
        :agent => false,
        :server => false,
        :port => 3370,
        :path => nil,
        :verbose => false
      }

      parse_options
    end

    #
    #
    #
    def self.run(args)
      cli = self.new(args)

      @proc = if cli.options[:collect]

        Proc.new do
          puts 'Starting Httpry Collection Server.'
          puts "Listening for connections on port: #{cli.options[:port]}"

          Httpry::Collect.start(cli.options)
        end

      elsif cli.options[:agent]

        Proc.new do
          puts 'Starting Httpry Agent.'
          puts "Attempting to connect to #{cli.options[:host]} " +
               "on port #{cli.options[:port]}"

          Httpry::Agent.start(cli.options)
        end

      elsif cli.options[:server]
        
        host = cli.options[:host] || '0.0.0.0'
        port = cli.options[:port].to_i || 3000

        Httpry::UI::Server.run!(:port => port,
                                :logging => cli.options[:verbose],
                                :bind => host,
                                :environment => :production)
      else
        raise("You must run as a collection server or agent.")
      end

      EM.run { @proc.call } unless cli.options[:server]
    end

    private

    def parse_options
      opts = OptionParser.new

      opts.banner = "rHttpry - Distributed Collection System.\nUsage: rhttpry --collect -p 8000\n\n"
      
      opts.on('-c','--collect','Start the httpry collection server.') do |collect|
        @options[:collect] = true
      end

      opts.on('-a ','--agent ','Start the httpry collection server.') do |path|
        @options[:agent] = true
        @options[:path] = File.expand_path(path)
        @options[:file] = File.new(@options[:path])
      end

      opts.on('-s','--server','Start the rhttpry web server.') do |server|
        @options[:server] = true
      end

      opts.on('-h ','--host ', 'Host for the agent to connect to.') do |host|
        @options[:host] = IPAddr.new(host)
      end

      opts.on('-p ','--port ', 'Port to listen on or send information to. Default: 3370') do |port|
        @options[:port] = port.to_i
      end

      opts.on('-H', '--help', 'Print application usage.') do |help|
        STDOUT.puts "#{opts}\n"
        exit -1
      end

      opts.on('-v', '--version', 'Print version information.') do |version|
        exit -1
      end

      opts.parse!(@args)
    end

  end # Class CLI End

end # Module Httpry End
