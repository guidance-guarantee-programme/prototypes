require 'bundler'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?

require 'slimmer'
require 'sass/plugin/rack'
require 'tilt/govspeak'

Sass.load_paths << Gem.loaded_specs['govuk_frontend_toolkit'].full_gem_path + '/app/assets/stylesheets'
Sass::Plugin.add_template_location('bower_components/govuk_elements/public/sass')

Tilt.prefer Tilt::GovspeakTemplate

use Rack::Auth::Basic, 'Prototype' do |username, password|
  [username, password] == [ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']]
end if production?

use Sass::Plugin::Rack
use Slimmer::App

configure do
  set :markdown, layout_engine: :erb
  set :server, :puma
end

get '/' do
  erb :index
end

get '/article' do
  erb :article
end

get '/guidance-session' do
  erb :guidance_session
end

get '/session-type' do
  erb :session_type
end

get '/find-a-local-branch' do
  erb :find_a_local_branch
end

get '/contact-details' do
  erb :contact_details
end

get '/book-a-session' do
  erb :book_a_session
end

get '/check-your-request' do
  erb :check_your_request
end

get '/request-sent' do
  erb :request_sent
end
