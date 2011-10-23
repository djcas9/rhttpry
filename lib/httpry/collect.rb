require 'httpry/collect/server'
require 'em-websocket'

module Httpry

  module Collect

    def self.clients
      @clients ||= Set.new
    end

    def self.channel
      @channel ||= EM::Channel.new
    end

    def self.start(options={})
      EventMachine.start_server("0.0.0.0", options[:port], 
                                Httpry::Collect::Server)


      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

        ws.onopen do
          @sid = Collect.channel.subscribe do |data|
            ws.send data
          end
        end

        ws.onclose { Collect.channel.unsubscribe(@sid) }
        ws.onmessage { |msg|
          puts "Recieved message: #{msg}"
          ws.send "Pong: #{msg}"
        }
      end

    end

  end

end


