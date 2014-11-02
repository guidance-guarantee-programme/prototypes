class AppointmentPresenter < SimpleDelegator

  # Slots from the MoJ slot picker are of the form '2014-11-12-1000-1100'
  # Present appointment slot as 'Friday, 12 November at 10am'
  def slot
    model.datetime.strftime('%A, %e %B at %l%P')
  end

  def date
    model.datetime.strftime('%e %B %Y')
  end

  def time
    model.datetime.strftime('%l%P')
  end

  private

  def model
    __getobj__
  end
end
