module Httpry

  class Parse

    attr_accessor :format, :line

    def initialize(line)
      @line = line
      @data = {}

      @format = [
        :date,
        :time, 
        :source_ip, 
        :dest_ip, 
        :direction, 
        :method, 
        :host, 
        :request_uri, 
        :http_version, 
        :status_code, 
        :reason_phrase
      ]

      process
    end

    def pack
      @data.to_msgpack
    end

    def json
      @data.to_json
    end

  private

  def process
    data = @line.split(' ').to_a

    count = 0
    @format.each do |key|
      @data[key] = data[count]
      count += 1
    end

    @data[:timestamp] = "#{@data[:date]} #{@data[:time]}"
  end

  end # Class Parse End
  
end # Module Httpry End
