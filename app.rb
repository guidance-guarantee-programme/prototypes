require 'bundler'
require 'bundler/setup'

require 'sinatra'
require 'slimmer'
require 'sass/plugin/rack'

Sass.load_paths << Gem.loaded_specs['govuk_frontend_toolkit'].full_gem_path + '/app/assets/stylesheets'

use Rack::Auth::Basic, 'Prototype' do |username, password|
  [username, password] == [ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']]
end if settings.production?

use Sass::Plugin::Rack
use Slimmer::App

get '/' do
  erb :index
end
