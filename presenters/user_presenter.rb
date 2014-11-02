class UserPresenter < SimpleDelegator

  def secret
    model.secret[0] + '*' * model.secret[1...-1].length + model.secret[-1]
  end

  private

  def model
    __getobj__
  end
end
