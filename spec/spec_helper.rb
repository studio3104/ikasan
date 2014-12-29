ENV['RACK_ENV'] = 'test'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'securerandom'
require 'ikasan/app'
require 'rspec'
require 'rack/test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Ikasan::App end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
