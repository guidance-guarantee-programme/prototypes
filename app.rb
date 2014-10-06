require 'bundler'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?

require 'phonelib'
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

Phonelib.default_country = 'GB'

get '/' do
  @hide_session_promo = false
  erb :index
end

get '/guidance-session' do
  @hide_session_promo = true
  erb :guidance_session
end

get '/session-type' do
  @hide_session_promo = true
  erb :session_type
end

get '/find-a-local-branch' do
  @hide_session_promo = true
  erb :find_a_local_branch
end

get '/local-branch-results' do
  @hide_session_promo = true
  erb :local_branch_results
end

get '/contact-details' do
  @hide_session_promo = true
  @name    = session[:name]
  @surname = session[:surname]
  @email   = session[:email]
  @phone   = session[:phone]

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
  @hide_session_promo = true
  erb :book_a_session
end

post '/book-a-session' do
  session[:slots] = params[:slots]

  redirect to('/check-your-booking')
end

get '/check-your-booking' do
  @hide_session_promo = true
  @name    = session[:name]
  @surname = session[:surname]
  @email   = session[:email]
  @phone   = session[:phone]
  @slots   = session[:slots]
  @number  = Phonelib.parse(ENV['TWILIO_FROM_NUMBER']).national

  @sessions = []

  # Slots are ['2014-11-12-1000-1100', '2014-11-12-1200-1300']
  @slots.reject(&:empty?).each do |slot|
    slot = slot.split('-').map(&:to_i)
    time = slot[3].to_s.scan(/.{2}/).map(&:to_i)

    @sessions << DateTime.new(slot[0], slot[1], slot[2], time[0], time[1])
  end

  session[:sessions] = @sessions

  erb :check_your_booking
end

post '/send-request' do
  name  = session[:name]
  phone = Phonelib.parse(session[:phone])
  slot = session[:sessions].first if session[:sessions]

  if phone.valid? && slot
    twilio = Twilio::REST::Client.new

    case phone.type
      when :mobile
        # SMS
        time = slot.strftime('%e %B at %l%P')
        sms = {
          from: ENV['TWILIO_FROM_NUMBER'],
          to: phone.international.gsub(/[[:space:]]/, ''),
          body: "Hi #{name}, you’re booked for a pensions guidance session on #{time}. A pensions expert will call you on this number."
        }

        twilio.account.messages.create sms

      when :fixed_line
        # Call
        call = {
          from: ENV['TWILIO_FROM_NUMBER'],
          to: phone.international.gsub(/[[:space:]]/, ''),
          url: "http://#{ENV['AUTH_USERNAME']}:#{ENV['AUTH_PASSWORD']}@ggp-sprint2-endtoend.herokuapp.com/reminder-call?name=#{name}&slot='#{slot}'",
          method: 'GET'
        }

        twilio.account.calls.create call
    end
  end

  redirect to('/booking-confirmation')
end

get '/reminder-call', provides: ['xml'] do
  name = params[:name]

  if params[:slot]
    slot = DateTime.parse(params[:slot])
    time = slot.strftime('%e %B at %l%P')
  end

  builder do |xml|
    xml.instruct!
    xml.Response do
      xml.Say "Hi #{name}, you’re booked for a pensions guidance session on #{time}. A pensions expert will call you on this number.", voice: 'alice', language: 'en-GB'
    end
  end
end

get '/booking-confirmation' do
  @hide_session_promo = true
  @phone    = session[:phone]
  @sessions = session[:sessions] || []

  erb :booking_confirmation
end

get '/govspeak' do
  markdown :govspeak, {:layout => :layout_govspeak}
end

get '/how-much-in-your-pot' do
  @hide_session_promo = false
  erb :'articles/how_much_in_pot'
end

get '/your-options/:option' do
  @hide_session_promo = false
  @page = params[:option]
  @page_title = "Deciding how you want your pension to be paid"
  @your_option_page_title_1 = "Overview"
  @your_option_page_title_2 = "Taking cash"
  @your_option_page_title_3 = "Taking money out when you need it"
  @your_option_page_title_4 = "Buying a regular income"
  @your_option_page_title_5 = "Mixing your options"

  erb :"articles/your_options/#{params[:option]}"
end

get '/tax-on-your-pension/:option' do
  @hide_session_promo = false
  @page = params[:option]
  @page_title = "Tax on your pension"
  @page_title_1 = "What’s tax-free"
  @page_title_2 = "What’s taxed and how much you pay"
  @page_title_3 = "How your tax is paid "
  erb :"articles/tax_on_your_pension/#{params[:option]}"
end

get '/how-pensions-work/:option' do
  @hide_session_promo = false
  @folder = 'how_pensions_work'
  @page = params[:option]
  @page_title = "How pensions work"
  @page_title_1 = "Overview"
  @page_title_2 = "Pensions from the government"
  @page_title_3 = "Private pension types"
  @page_title_4 = "How much you get"
  @page_title_5 = "Shopping around"
  erb :"articles/#{@folder}/#{params[:option]}"
end


