class AppointmentPresenter < SimpleDelegator

  # Slots from the MoJ slot picker are of the form '2014-11-12-1000-1100'
  # Present appointment slot as 'Friday, 12 November at 10am'
  def slot
    date = model.slot.split('-').map(&:to_i)
    time = date[3].to_s.scan(/.{2}/).map(&:to_i)
    datetime = DateTime.new(date[0], date[1], date[2], time[0], time[1])
    datetime.strftime('%A, %e %B at %l%P')
  end

  private

  def model
    __getobj__
  end
end
