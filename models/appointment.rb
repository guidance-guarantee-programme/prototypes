require 'active_model'

class Appointment
  include ActiveModel::Model

  validates_presence_of :slot

  attr_accessor :slot
end
