require 'httpry/collect/server'
require 'em-mongo'
require 'em-websocket'

module Httpry

  module Collect

    @@channel = nil

    def self.clients
      @clients ||= Set.new
    end

    def self.web_clients
      @web_clients ||= Set.new
    end

    def self.channel
      @@channel ||= EM::Channel.new
    end

    def self.events
      @events ||= Collect.database.collection('events')
    end

    def self.database
      @database ||= EM::Mongo::Connection.new('localhost').db('rhttpry')
    end

    def self.start(options={})
      # DEBUG
      EventMachine::PeriodicTimer.new(5) do     
        Collect.channel.push({
            :type => :ping,
            :data => 'PING'
          }.to_json)
      end
      #

      db = Collect.database
      collection = Collect.events
      
      EventMachine.start_server("0.0.0.0", options[:port], 
                                Httpry::Collect::Server)


      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

        ws.onopen do
          Collect.web_clients << ws

          sid = Collect.channel.subscribe do |data|
            ws.send data
          end

          ws.onclose do
            Collect.web_clients.delete(ws)
            Collect.channel.unsubscribe(sid)
          end

          ws.onmessage do |msg|
            puts "Recieved message: #{msg} from #{sid}"
          end

        end # ws.onopen

      end
    end
  end

end


