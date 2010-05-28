require 'rubygems'
require 'sinatra'
 
set :env, :production
disable :run

require 'app'

run Sinatra::Application