# a helper script to load this locally

require 'sinatra'
require 'sinatra/reloader'

puts :env
set :env, :development
puts :env

#require 'app'