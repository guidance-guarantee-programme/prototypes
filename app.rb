require 'bundler'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?

require 'slimmer'
require 'sass/plugin/rack'
require 'tilt/govspeak'
require 'twilio-ruby'

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
  set :sessions, true
end

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
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

get '/local-branch-results' do
  erb :local_branch_results
end

get '/contact-details' do
  erb :contact_details
end

post '/contact-details' do
  session[:name]    = params[:name]
  session[:surname] = params[:surname]
  session[:email]   = params[:email]
  session[:phone]   = params[:phone]

  redirect to('/book-a-session')
end

get '/book-a-session' do
  erb :book_a_session
end

post '/book-a-session' do
  session[:slots] = params[:slots]

  redirect to('/check-your-request')
end

get '/check-your-request' do
  erb :check_your_request
end

get '/request-sent' do
  erb :request_sent
end
