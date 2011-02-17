require 'rubygems'
require 'sinatra'
require './server.rb'

# always put this line last so that all of your settings are properly loaded before sinatra is booted up
run Sinatra::Application