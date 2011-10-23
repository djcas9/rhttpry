module Httpry

  module Agent

    class Connect < EM::Connection

      def post_init
        start_tls
        Agent.connection = self
      end

      def ssl_handshake_completed
        puts 'Secure connection successfully established.'
        Agent.ready = true
      end

      def receive_data(data)
        close_connection if data =~ /exit\n/
      end
      
      def unbind
        puts 'Disconnected from server.'
      end

    end # Class Connect End

  end # Module Agent End
  
end # Module Httpry End
