require File.dirname(__FILE__) + '/test_helper'

class MoneyHelperTest < ActiveSupport::TestCase
  include RedmineCrm::MoneyHelper

  def test_price_to_currency
    assert_equal '$3,265.65', price_to_currency(3265.65, 'USD')
    assert_equal '3.265,65 RUB', price_to_currency(3265.65, 'RUB')
    assert_equal '3,200.0', price_to_currency(3200, '')
    assert_equal '3,200.0', price_to_currency(3200, 'Foo')
  end
end
