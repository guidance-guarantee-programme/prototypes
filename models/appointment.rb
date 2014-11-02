require 'active_model'

class Appointment
  include ActiveModel::Model

  validates_presence_of :slot

  attr_accessor :slot

  def datetime
    date = slot.split('-').map(&:to_i)
    time = date[3].to_s.scan(/.{2}/).map(&:to_i)
    DateTime.new(date[0], date[1], date[2], time[0], time[1])
  end
end
