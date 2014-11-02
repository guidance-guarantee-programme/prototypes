use Rack::Auth::Basic, 'Prototype' do |username, password|
  [username, password] == [ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']]
end if production?

use Sass::Plugin::Rack
use Slimmer::App

configure do
  set :app_file, __FILE__
  set :markdown, layout_engine: :erb
  set :server, :puma
  set :sessions, true
end

get '/' do
  @hide_session_promo = false
  erb :index
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
    session.clear

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
  @page_title = "Income Tax and your pension"
  @page_title_1 = "What’s tax-free"
  @page_title_2 = "What’s taxed and how much you pay"
  @page_title_3 = "How your tax is paid "
  erb :"articles/tax_on_your_pension/#{params[:option]}"
end

get '/understanding-pensions/:option' do
  @hide_session_promo = false
  @folder = 'understanding_pensions'
  @page = params[:option]
  @page_title = "Understanding pensions"
  @page_title_1 = "Overview"
  @page_title_2 = "Pensions from the government"
  @page_title_3 = "Pension types"
  @page_title_4 = "How much you get"
  @page_title_5 = "Shopping around"
  erb :"articles/#{@folder}/#{params[:option]}"
end


