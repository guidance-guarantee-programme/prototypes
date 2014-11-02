require 'rubygems'
require 'bundler'

require_relative 'govuk_frontend_toolkit'

Bundler.require(:default, ENV['RACK_ENV'])

Dir['./models/*.rb'].each { |file| require file }
Dir['./config/initialisers/**/*.rb'].each { |file| require file }
