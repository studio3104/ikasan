require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'ikasan/helper'

module Ikasan
  class App < Sinatra::Base
    configure do
      Slim::Engine.default_options[:pretty] = true
      set :root, File.dirname(__FILE__) + '/../..'
      set :public_folder, settings.root + '/public'
      set :views, settings.root + '/views'
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      set :show_exception, false
      set :show_exception, :after_handler
    end

    helpers do
      include Ikasan::Helper
    end

    get '/' do
      @mappings = room_mapping_of()
      slim :index
    end

    post '/join' do
    end

    post '/leave' do
    end

    post '/notice' do
      req_params = validate(params.merge(notify: '0'))

      if req_params.has_error?
        halt 400, req_params.errors.values.to_json
      end

      result = enqueue_message(req_params.hash)
      json result
    end

    post '/privmsg' do
      req_params = validate(params.merge(notify: '1'))

      if req_params.has_error?
        halt 400, req_params.errors.values.to_json
      end

      result = enqueue_message(req_params.hash)
      json result
    end
  end
end
