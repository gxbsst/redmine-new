require File.dirname(__FILE__) + '/../liquid_helper'
include LiquidHelperMethods

module RedmineCrm
  class BaseFilterTest < ActiveSupport::TestCase
    def setup
      @liquid_render = LiquidRender.new
    end

    def test_underscore_filter
      assert_match 'some_text', @liquid_render.render("{{ 'some text' | underscore }}")
    end

    def test_dasherize_filter
      assert_match 'some-text', @liquid_render.render("{{ 'some text' | dasherize }}")
    end

    def test_random_filter
      assert @liquid_render.render("{{ random: 10 }}").to_i <= 10
    end

    def test_encode_filter
      assert_equal 'http%3A%3A%2F%2Fwww.test.com%3Fkey%3Dtest+test+test',
                   @liquid_render.render("{{ 'http:://www.test.com?key=test test test' | encode }}")
    end

    def test_plus_days_filter
      assert_match (Date.today + 3.days).strftime(date_format), @liquid_render.render("{{today | plus_days: 3 | date: '#{date_format}'}}")
    end

    def test_date_range_filter
      assert_equal '10', @liquid_render.render("{{today | date_range: '#{Date.today - 10.days}'}}")
    end

    def test_today_filter
      assert_match Date.today.strftime(date_format), @liquid_render.render('{{today}}')
    end

    def test_utc_filter
      assert_match '2017-01-01 10:13:13 UTC', @liquid_render.render("{{'San, 01 Jan 2017 13:13:13 MSK +03:00' | utc}}")
    end

    def test_modulo_filter
      assert_equal '3', @liquid_render.render("{{24 | modulo: 7}}")
    end

    def test_round_filter
      assert_equal '24.12', @liquid_render.render("{{24.12345 | round: 2}}")
    end

    def test_ceil_filter
      assert_equal '25', @liquid_render.render("{{24.11 | ceil }}")
    end

    def test_floor_filter
      assert_equal '24', @liquid_render.render("{{24.99 | floor }}")
    end

    def test_currency_filter
      assert_equal '99,99 RUB', @liquid_render.render("{{99.99 | currency: 'RUB' }}")
    end
  end
end
