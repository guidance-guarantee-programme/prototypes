require 'active_model'

class User
  include ActiveModel::Model

  validates_presence_of :name, :surname, :email, :phone, :secret

  attr_accessor :name, :surname, :email, :phone, :secret
end
