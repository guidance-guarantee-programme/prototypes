class Reminder

  FROM_NUMBER = ENV['TWILIO_FROM_NUMBER']
  CALLBACK_URL = "http://#{ENV['AUTH_USERNAME']}:#{ENV['AUTH_PASSWORD']}@ggp-20141106-alpha.herokuapp.com/reminder-call"

  def initialize(user, appointment)
    @user = user
    @appointment = appointment
    @twilio = Twilio::REST::Client.new
  end

  def deliver
    phone = Phonelib.parse(@user.phone)

    case phone.type
      when :mobile then sms
      when :fixed then call
    end
  end

  private

  def sms
    phone = Phonelib.parse(@user.phone)
    time = @appointment.datetime.strftime('%e %B at %l%P')

    sms = {
        from: FROM_NUMBER,
        to: phone.international.gsub(/[[:space:]]/, ''),
        body: "Hi #{@user.name}, you’re booked for a pensions guidance session on #{time}. A pensions expert will call you on this number."
    }

    @twilio.account.messages.create sms
  end

  def call
    phone = Phonelib.parse(@user.phone)

    call = {
        from: FROM_NUMBER,
        to: phone.international.gsub(/[[:space:]]/, ''),
        url: CALLBACK_URL + "?name=#{@user.name}&slot='#{@appointment.datetime}'",
        method: 'GET'
    }

    @twilio.account.calls.create call
  end

end
