require 'rubygems'
require 'bundler'

require_relative 'govuk_frontend_toolkit'

Bundler.require(:default, ENV['RACK_ENV'])

Dir['./config/initialisers/**/*.rb'].each { |file| require file }
