ENV['RACK_ENV'] = 'test'

require_relative 'config/application'
require_relative 'app'

require 'minitest/autorun'

Dotenv.load

class SmokeTest <  Minitest::Test
  include Capybara::DSL

  def setup
    Capybara.app = Prototype.new
  end

  def teardown
    Capybara.reset_sessions!
  end

  def test_homepage
    visit '/'

    assert page.has_content? 'The Pensions Guidance Service'
  end
end
