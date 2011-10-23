require 'json'
require 'set'

module Httpry

  module Collect

    class Server < EventMachine::Connection

      def post_init
        puts 'New Agent Connected'
        start_tls

        @pac = MessagePack::Unpacker.new
      end

      def ssl_handshake_completed
        Collect.clients << self
      end

      def receive_data(data)
        @pac.feed data
        
        @pac.each do |obj|
          message_received(obj)
        end
      end
      
      def message_received(obj)
        puts obj.to_json
        Collect.channel.push obj.to_json
      end

      def unbind
        puts 'Agent Disconnected'
        Collect.clients.delete self
      end

    end # Class Server End

  end # Module Collect End
  
end # Module Httpry End
