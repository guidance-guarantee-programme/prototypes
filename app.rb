require 'sinatra/base'
require 'sinatra/contrib'

class Prototype < Sinatra::Base
  register Sinatra::Contrib

  use Sass::Plugin::Rack
  use Slimmer::App

  configure do
    set :app_file, __FILE__
    set :markdown, layout_engine: :erb
    set :server, :puma
    set :sessions, true
  end

  configure :development do
    register Sinatra::Reloader

    also_reload 'models/*.rb'
    also_reload 'presenters/*.rb'
  end

  configure :production do
    use Rack::Auth::Basic, 'Prototype' do |username, password|
      [username, password] == [ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']]
    end
  end

  get '/' do
    erb :index, {:layout => :layout_homepage}
  end

  get '/appointments' do
    @hide_session_promo = true

    erb :'appointments/index'
  end

  get '/appointments/overview' do
    @hide_session_promo = true

    erb :'appointments/overview'
  end

  get '/appointments/face-to-face/search' do
    @hide_session_promo = true

    erb :'appointments/f2f/results'
  end

  get '/appointments/phone/availability' do
    @hide_session_promo = true
    @current_step = 1

    erb :'appointments/phone/calendar'
  end

  post '/appointments/phone/book' do
    appointment = Appointment.new(slot: params[:slots].first)

    session[:appointment] = appointment

    if appointment.valid?
      redirect to('/appointments/phone/contact-details')
    else
      redirect to('/appointments/phone/availability')
    end
  end

  get '/appointments/phone/contact-details' do
    @hide_session_promo = true
    @current_step = 2

    @user = session[:user] || User.new

    erb :'appointments/phone/contact_details'
  end

  post '/appointments/phone/contact-details' do
    user = User.new(params[:user])

    session[:user] = user

    if user.valid?
      redirect to('/appointments/phone/preview')
    else
      redirect to('/appointments/phone/contact-details')
    end
  end

  get '/appointments/phone/preview' do
    @hide_session_promo = true
    @current_step = 3

    @user = UserPresenter.new(session[:user])
    @appointment = AppointmentPresenter.new(session[:appointment])

    erb :'appointments/phone/preview'
  end

  post '/appointments/phone/confirm' do
    user = session[:user]
    appointment = session[:appointment]
    phone = Phonelib.parse(user.phone)

    if phone.valid?
      reminder = Reminder.new(user, appointment)
      reminder.deliver

      redirect to('/appointments/phone/confirmation')
    else
      redirect to('/appointments/phone/preview')
    end
  end

  get '/reminder-call', provides: ['xml'] do
    @name = params[:name]

    if params[:slot]
      slot = DateTime.parse(params[:slot])
      @time = slot.strftime('%e %B at %l%P')
    end

    builder :'appointments/reminder_call'
  end

  get '/appointments/phone/confirmation' do
    @hide_session_promo = true
    @current_step = 4

    @user = UserPresenter.new(session[:user])
    @appointment = AppointmentPresenter.new(session[:appointment])

    erb :'appointments/phone/confirmation'
  end

  get '/govspeak' do
    markdown :govspeak, {:layout => :layout_govspeak}
  end

  get '/how-much-in-your-pot' do
    @hide_session_promo = false
    erb :'articles/how_much_in_pot'
  end

  get '/what-you-can-do-with-your-pension-pot' do
    @hide_session_promo = true
    erb :'articles/what_you_can_do_with_your_pension_pot'
  end

  get '/pension-tax-calculator' do
    @hide_session_promo = false
    erb :'pension_tax_calculator'
  end

  get '/tax-you-pay-on-your-pension' do
    @hide_session_promo = true
    erb :'articles/tax_you_pay_on_your_pension'
  end

  get '/understand-your-pension-type' do
    @hide_session_promo = true

    erb :'articles/understand_your_pension_type'
  end

  get '/shopping-around-for-the-best-deal' do
    @hide_session_promo = true
    erb :"articles/shopping_around_for_the_best_deal"
  end

  get '/edge', '/search' do
    @hide_session_promo = true

    erb :edge
  end
end
