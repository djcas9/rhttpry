require 'httpry/parse'

module Httpry

  module Agent

    class Reader < EventMachine::FileTail

      def initialize(path, startpos=-1)
        super(path, startpos)
                
        puts "Monitoring File: #{path}"
        @buffer = BufferedTokenizer.new
      end

      def receive_data(data)
        
        @buffer.extract(data).each do |line|
          next if line[/^\#/]

          data = Parse.new(line).pack
          Agent.push(data) if Agent.ready
        end

      end

    end # Class Reader End

  end # Module Agent End
  
end # Module Httpry End
