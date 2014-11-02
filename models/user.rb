require 'active_model'

class User
  include ActiveModel::Model

  validates_presence_of :name, :surname, :email, :phone

  attr_accessor :name, :surname, :email, :phone
end
