require File.dirname(__FILE__) + '/../liquid_helper'
include LiquidHelperMethods

module RedmineCrm
  class NewsDropTest < ActiveSupport::TestCase
    def setup
      @news = News.first
      @user = User.first
      @liquid_render = LiquidRender.new('user' => Liquid::UserDrop.new(@user),
                                        'news' => Liquid::NewsDrop.new(@news),
                                        'newss' => Liquid::NewssDrop.new(News.all))
    end

    def test_newss_all
      newss_text = @liquid_render.render('{% for news in newss.all %} {{news.title }} {% endfor %}')
      News.all.map(&:title).each do |title|
        assert_match title, newss_text
      end
    end

    def test_newss_last
      assert_equal News.last.title, @liquid_render.render('{{ newss.last.title }}')
    end

    def test_newss_size
      assert_equal '2', @liquid_render.render('{{ newss.size }}')
    end

    def test_news_author
      assert_equal @user.name, @liquid_render.render('{{ news.author.name }}')
    end

    def test_issue_delegated
      assert_equal [@news.id, @news.title, @news.description].join('|'),
                   @liquid_render.render('{{ news.id }}|{{ news.title }}|{{ news.description }}')
    end
  end
end
