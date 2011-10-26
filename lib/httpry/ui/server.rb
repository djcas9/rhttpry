require 'sinatra'
require 'sinatra/async'

module Httpry
  
  module UI
    
    class Server < Sinatra::Base
      include Httpry::Collect
      register Sinatra::Async

      set :root, File.expand_path(File.join(File.dirname(__FILE__)))

      aget '/' do
        
        EM.next_tick do
          events = Collect.events.find({}, {:order => 'timestamp'}).limit(500).to_a
          events.callback do |documents|
            body do 
              @events = documents.to_json
              erb :index
            end
          end
        end

      end # '/'

    end
  end
end
