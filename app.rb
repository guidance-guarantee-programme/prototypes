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

  get '/your-options/:option' do
    @hide_session_promo = false
    @page = params[:option]
    @page_title = "What you can do with your pension pot"
    @your_option_page_title_1 = "Options you have"
    @your_option_page_title_2 = "Do nothing"
    @your_option_page_title_3 = "Take 25% tax free"
    @your_option_page_title_4 = "Take your whole pot as cash"
    @your_option_page_title_5 = "Take money out when you need it (income drawdown)"
    @your_option_page_title_6 = "Get a guaranteed income (annuity)"
    @your_option_page_title_7 = "Mix your pension options"
    erb :"articles/your_options/#{params[:option]}"
  end

  get '/pension-tax-calculator' do
    @hide_session_promo = false
    erb :'pension_tax_calculator'
  end

  get '/tax-on-your-pension/:option' do
    @hide_session_promo = false
    @page = params[:option]
    @page_title = "Tax you pay on your pension"
    @page_title_1 = "What you pay tax on"
    @page_title_2 = "What’s tax free"
    @page_title_3 = "How much tax you pay"
    @page_title_4 = "How your tax is paid"
    erb :"articles/tax_on_your_pension/#{params[:option]}"
  end

  get '/understand-your-pension-type' do
    @hide_session_promo = true

    erb :'articles/understand_your_pension_type'
  end

  get '/shop-around/:option' do
    @hide_session_promo = false
    @folder = 'shop_around'
    @page = params[:option]
    @page_title = "Shopping around for the best deal"
    @page_title_1 = "Overview"
    @page_title_2 = "Comparing annuities"
    @page_title_3 = "Comparing income drawdown products"
    @page_title_4 = "Getting financial advice"
    erb :"articles/#{@folder}/#{params[:option]}"
  end

  get '/edge', '/search' do
    @hide_session_promo = true

    erb :edge
  end
end
