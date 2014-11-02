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

get '/guidance-session' do
  @hide_session_promo = true
  erb :guidance_session
end

get '/session-type' do
  @hide_session_promo = true
  erb :session_type
end

get '/local-branch-results' do
  @hide_session_promo = true
  erb :local_branch_results
end

get '/book-a-session' do
  @hide_session_promo = true
  @current_step = 1

  erb :book_a_session
end

post '/book-a-session' do
  appointment = Appointment.new(slot: params[:slots].first)

  session[:appointment] = appointment

  if appointment.valid?
    redirect to('/contact-details')
  else
    redirect to('/book-a-session')
  end
end

get '/contact-details' do
  @hide_session_promo = true
  @current_step = 2

  @user = session[:user] || User.new

  erb :contact_details
end

post '/contact-details' do
  user = User.new(params[:user])

  session[:user] = user

  if user.valid?
    redirect to('/check-your-booking')
  else
    redirect to('/contact-details')
  end
end

get '/check-your-booking' do
  @hide_session_promo = true
  @current_step = 3

  @user = UserPresenter.new(session[:user])
  @appointment = AppointmentPresenter.new(session[:appointment])

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
  @name = params[:name]

  if params[:slot]
    slot = DateTime.parse(params[:slot])
    @time = slot.strftime('%e %B at %l%P')
  end

  builder :'appointments/reminder_call'
end

get '/booking-confirmation' do
  @hide_session_promo = true
  @phone    = session[:phone]
  @email    = session[:email]
  @sessions = session[:sessions] || []
  @number  = Phonelib.parse(ENV['TWILIO_FROM_NUMBER']).national

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


