require File.dirname(__FILE__) + '/../liquid_helper'
include LiquidHelperMethods

module RedmineCrm
  class ArraysFilterTest < ActiveSupport::TestCase
    def setup
      @liquid_render = LiquidRender.new
      @array = '6,7,8,9,1,2,3,4,5'
    end

    def test_first_filter
      assert_match '1', @liquid_render.render("{{ '#{@array}' | split: ',' | first: 5 | last }}")
    end

    def test_sort_filter
      assert_match '123456789', @liquid_render.render("{{ '#{@array}' | split: ',' | sort }}")
    end

    def test_where_filter
      assert_match '{"name"=>"two", "value"=>5}', @liquid_render.render("{{ objects_arr | where: 'name', 'two' }}")
    end

  end
end
