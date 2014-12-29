$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'ikasan/app'

run Ikasan::App
