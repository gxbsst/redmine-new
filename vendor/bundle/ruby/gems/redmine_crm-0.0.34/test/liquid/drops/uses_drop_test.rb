require File.dirname(__FILE__) + '/../liquid_helper'
include LiquidHelperMethods

module RedmineCrm
  class UsersDropTest < ActiveSupport::TestCase
    def setup
      @user = User.first
      @liquid_render = LiquidRender.new('user' => Liquid::UserDrop.new(@user),
                                        'users' => Liquid::UsersDrop.new(User.all))
    end

    def test_users_all
      users_text = @liquid_render.render('{% for user in users.all %} {{user.name }} {% endfor %}')
      User.all.map(&:name).each do |name|
        assert_match name, users_text
      end
    end

    def test_users_current
      assert_equal User.first.name, @liquid_render.render('{{ users.current.name }}')
    end

    def test_users_size
      assert_equal '2', @liquid_render.render('{{ users.size }}')
    end

    def test_user_name
      assert_equal @user.name, @liquid_render.render('{{ user.name }}')
    end

    def test_user_delegated
      assert_equal [@user.name, @user.language].join('|'),
                   @liquid_render.render('{{ user.name }}|{{ user.language }}')
    end
  end
end
