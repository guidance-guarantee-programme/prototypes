require 'dotenv'
Dotenv.load

ENV['RACK_ENV'] = 'test'

require_relative 'config/application'
require_relative 'app'

require 'minitest/autorun'

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

  def test_book_appointment
    visit '/'
    click_on('speak to a pension expert')
    click_on('Start now')
    click_on('Book a phone session')

    # Pick a date and time
    select('Wednesday, 17 December - 4:00pm', from: 'slots[]')
    click_on('Continue')

    # Fill in contact details
    within('.form') do
      fill_in('First name', with: 'Clark')
      fill_in('Last name', with: 'Kent')
      fill_in('Email', with: 'clark.kent@gmail.com')
      fill_in('Phone number to call you on', with: '07460123456')
      fill_in('Memorable word', with: 'cryptonite')
    end

    click_on('Continue')

    # Confirm booking
    click_on('Confirm booking')

    assert page.has_content? 'You’ve successfully booked a pension guidance session'
  end

  def test_find_local_branch
    visit '/'
    click_on('speak to a pension expert')
    click_on('Start now')

    # Fill in postcode
    within('.form') do
      fill_in('Postcode', with: 'SW18 4XP')
    end

    click_on('Find a local branch')

    assert page.has_content? 'Tooting'
  end

  def test_tax_calculator
    visit '/pension-tax-calculator'

    # Fill in pension and income
    fill_in('pension', with: '10000')
    fill_in('income', with: '10000')

    click_on('Calculate')

    assert page.has_content? 'Total amount you may get after tax'
  end
end
