require 'rubygems'
require 'sinatra'
 
set :env,  :debug
disable :run

require 'app'

run Sinatra::Application