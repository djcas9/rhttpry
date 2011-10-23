require 'eventmachine-tail'

require 'httpry/agent/connect'
require 'httpry/agent/reader'

module Httpry

  module Agent

    class << self
      attr_accessor :connection, :ready
    end

    def self.push(data)
      @connection.send_data(data)
    end

    def self.start(options={})
      EventMachine::connect(options[:host].to_s, 
      options[:port], Httpry::Agent::Connect)

      EventMachine::file_tail(options[:path], Httpry::Agent::Reader)      
    end

  end # Module Agent End
  
end # Module Httpry End

