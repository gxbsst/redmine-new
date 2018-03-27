require File.dirname(__FILE__) + '/test_helper'

module RedmineCrm
  class CurrencyTest < ActiveSupport::TestCase
    FOO = '{ "priority": 1, "iso_code": "FOO", "iso_numeric": "840", "name": "United States Dollar", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 100, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": ",", "smallest_denomination": 1 }'
    def register_foo(opts={})
      foo_attrs = JSON.parse(FOO, :symbolize_names => true)
      # Pass an array of attribute names to 'skip' to remove them from the 'FOO'
      # json before registering foo as a currency.
      Array(opts[:skip]).each { |attr| foo_attrs.delete(attr) }
      RedmineCrm::Currency.register(foo_attrs)
    end

    def unregister_foo
      Currency.unregister(JSON.parse(FOO, :symbolize_names => true))
    end

    def test_unknown_currency
      assert_equal true, (Currency::UnknownCurrency < ArgumentError)
    end

    def test_matching_by_id
      register_foo
      foo = Currency.new(:foo)
      assert_equal Currency.find(:foo), foo
      assert_equal Currency.find(:FOO), foo
      assert_equal Currency.find("foo"), foo
      assert_equal Currency.find("FOO"), foo
      unregister_foo
    end

    def test_nil_unless_matching_given_id
      assert_nil Currency.find("ZZZ")
    end

    class Mock
      def to_s
        '208'
      end
    end

    def test_matching_by_given_numeric_code
      assert_equal Currency.find_by_iso_numeric(978), Currency.new(:eur)
      assert_not_equal Currency.find_by_iso_numeric(208), Currency.new(:eur)
      assert_equal Currency.find_by_iso_numeric('840'), Currency.new(:usd)

      assert_equal Currency.find_by_iso_numeric(Mock.new), Currency.new(:dkk)
      assert_not_equal Currency.find_by_iso_numeric(Mock.new), Currency.new(:usd)
    end

    def test_nil_if_no_currency_has_the_given_num_code
      assert_nil Currency.find_by_iso_numeric("non iso 4217 numeric code")
      assert_nil Currency.find_by_iso_numeric(0)
    end

    # .all
    def test_array_of_currencies
      assert Currency.all.include?(Currency.new(:usd))
    end

    def test_include_register_currencies
      register_foo
      assert Currency.all.include?(Currency.new(:foo))
      unregister_foo
    end

    def test_sort_by_priority
      assert_equal Currency.all.first.priority, 1
    end

    def test_raises_missing_attributes_error_if_no_priority
      register_foo(:skip => :priority)
      assert_raises Currency::MissingAttributeError do
        Currency.all
      end
      unregister_foo
    end

    #.register
    def test_register_new_currency
      Currency.register(
        iso_code: "XXX",
        name: "Golden Doubloon",
        symbol: "%",
        subunit_to_unit: 100
      )
      new_currency = Currency.find("XXX")
      assert_not_equal nil, new_currency
      assert_equal "Golden Doubloon", new_currency.name
      assert_equal "%", new_currency.symbol
      Currency.unregister(iso_code: "XXX")
    end

    def test_present_iso_code
      assert_raises KeyError do
        Currency.register(name: "New currency")
      end
    end

    # .unregister
    def test_unregister_currency
      Currency.register(iso_code: "XXX")
      assert_not_equal nil, Currency.find("XXX")
      Currency.unregister(iso_code: "XXX")
      assert_nil Currency.find("XXX")
    end

    def test_exitred_currency
      Currency.register(iso_code: "XXX")
      assert_equal true, Currency.unregister(iso_code: "XXX")
      assert_equal false, Currency.unregister(iso_code: "XXX")
    end

    def test_passed_iso_code
      Currency.register(iso_code: "XXX")
      Currency.register(iso_code: "YYZ")
      #test with string
      Currency.unregister("XXX")
      assert_nil Currency.find("XXX")
      #test with symbol
      Currency.unregister(:yyz)
      assert_nil Currency.find(:yyz)
    end

    # .each
    def test_each_currency_to_block
      assert_equal true, Currency.respond_to?(:each)
      currencies = []
      Currency.each do |currency|
        currencies.push(currency)
      end

      assert_equal currencies[0], Currency.all[0]
      assert_equal currencies[1], Currency.all[1]
      assert_equal currencies[-1], Currency.all[-1]
    end

    # enumerable
    def test_implemants_enumerable
      assert_equal true, Currency.respond_to?(:all?)
      assert_equal true, Currency.respond_to?(:each_with_index)
      assert_equal true, Currency.respond_to?(:map)
      assert_equal true, Currency.respond_to?(:select)
      assert_equal true, Currency.respond_to?(:reject)
    end

    # #initialize
    def test_lookups_data_from_loading_config
      currency = Currency.new("USD")
      assert_equal :usd, currency.id
      assert_equal 1, currency.priority
      assert_equal "USD", currency.iso_code
      assert_equal "840", currency.iso_numeric
      assert_equal "United States Dollar", currency.name
      assert_equal ".", currency.decimal_mark
      assert_equal ".", currency.separator
      assert_equal ",", currency.thousands_separator
      assert_equal ",", currency.delimiter
      assert_equal 1, currency.smallest_denomination
    end

    def test_raises_with_unknown_currency
      assert_raises Currency::UnknownCurrency do
        Currency.new("xxx")
      end
    end

    # #<=>
    def test_compare_by_priority
      assert Currency.new(:cad) > Currency.new(:usd)
      assert Currency.new(:usd) < Currency.new(:eur)
    end

    def test_compares_by_id_with_same_priority
      Currency.register(iso_code: "ABD", priority: 15)
      Currency.register(iso_code: "ABC", priority: 15)
      Currency.register(iso_code: "ABE", priority: 15)
      abd = Currency.find("ABD")
      abc = Currency.find("ABC")
      abe = Currency.find("ABE")
      assert abd > abc
      assert abe > abd
      Currency.unregister("ABD")
      Currency.unregister("ABC")
      Currency.unregister("ABE")
    end

    # when one of the currencies has no 'priority' set
    def test_compare_by_id
      Currency.register(iso_code: "ABD") # No priority
      abd = Currency.find(:abd)
      usd = Currency.find(:usd)
      assert abd < usd
      Currency.unregister(iso_code: "ABD")
    end

    # "#=="
    def test_strong_equal
      eur = Currency.new(:eur)
      assert eur === eur
    end

    def test_equal_id_in_different_case
      assert_equal Currency.new(:eur), Currency.new(:eur)
      assert_equal Currency.new(:eur), Currency.new(:EUR)
      assert_not_equal Currency.new(:eur), Currency.new(:usd)
    end

    def test_direct_comparison_currency_and_symbol_string
      assert_equal Currency.new(:eur), 'eur'
      assert_equal Currency.new(:eur), 'EUR'
      assert_equal Currency.new(:eur), :eur
      assert_equal Currency.new(:eur), :EUR
      assert_not_equal Currency.new(:eur), 'usd'
    end

    def test_comparison_with_nil
      assert_not_equal nil, Currency.new(:eur)
    end

    #eql?
    def test_eql
      assert Currency.new(:eur).eql?(Currency.new(:eur))
      assert !Currency.new(:eur).eql?(Currency.new(:usd))
    end

    # hash
    def test_return_same_value_for_equal_objects
      assert_equal Currency.new(:eur).hash, Currency.new(:eur).hash
      assert_not_equal Currency.new(:eur).hash, Currency.new(:usd).hash
    end

    def test_return_intersection_for_array_of_object
      intersection = [Currency.new(:eur), Currency.new(:usd)] & [Currency.new(:eur)]
      assert_equal intersection, [Currency.new(:eur)]
    end

    # inspect
    def test_work_as_documented
      assert_equal Currency.new(:usd).inspect, %Q{#<RedmineCrm::Currency id: usd, priority: 1, symbol_first: true, thousands_separator: ,, html_entity: $, decimal_mark: ., name: United States Dollar, symbol: $, subunit_to_unit: 100, exponent: 2.0, iso_code: USD, iso_numeric: 840, subunit: Cent, smallest_denomination: 1>}
    end

    # to_s
    def test_to_s
      assert_equal Currency.new(:usd).to_s, "USD"
      assert_equal Currency.new(:eur).to_s, "EUR"
    end

    def test_to_sym
      assert_equal Currency.new(:usd).to_sym, :USD
      assert_equal Currency.new(:eur).to_sym, :EUR
    end

    #  to_currency
    def test_to_currency
      usd = Currency.new(:usd)
      assert_equal usd.to_currency, usd
    end

    def test_doesnt_create_new_symbol_indefiniteily
      assert_raises Currency::UnknownCurrency do
        Currency.new("bogus")
      end
      assert !Symbol.all_symbols.map{|s| s.to_s}.include?("bogus")
    end

    # code
    def test_code_as_documented
      assert_equal Currency.new(:usd).code, "$"
      assert_equal Currency.new(:azn).code, "\u20BC"
    end

    # exponent
    def test_conform_to_iso_4217
      assert Currency.new(:jpy).exponent == 0
      assert Currency.new(:usd).exponent == 2
      assert Currency.new(:iqd).exponent == 3
    end

    # decimal_places
    def test_proper_place_for_know_currency
      assert Currency.new(:mro).decimal_places == 1
      assert Currency.new(:usd).decimal_places == 2
    end

    def test_proper_place_for_custom_currency
      register_foo
      assert_equal 2, Currency.new(:foo).decimal_places
      unregister_foo
    end
  end
end
