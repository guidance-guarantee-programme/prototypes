class UserPresenter < SimpleDelegator

  def secret
    model.secret
  end

  private

  def model
    __getobj__
  end
end
