module RedmineCrm
  module Liquid
    class UsersDrop < ::Liquid::Drop

      def self.default_drop
        self.new User.sorted
      end

      def initialize(users)
        @users = users
      end

      def before_method(login)
        user = @users.where(:login => login).first || User.new
        UserDrop.new user
      end

      def current
        UserDrop.new User.current
      end

      def all
        @all ||= @users.map do |user|
          UserDrop.new user
        end
      end

      def each(&block)
        all.each(&block)
      end

      def size
        @users.size
      end
    end

    class UserDrop < ::Liquid::Drop
      delegate :id, :name, :firstname, :lastname, :mail, :active?, :admin?, :logged?, :language, :to => :@user

      def initialize(user)
        @user = user
      end

      def avatar
        ApplicationController.helpers.avatar(@user)
      end

      def name
        @user.name
      end

      def permissions
        roles = @user.memberships.collect { |m| m.roles }.flatten.uniq
        roles << (@user.logged? ? Role.non_member : Role.anonymous)
        roles.map(&:permissions).flatten.uniq.map(&:to_s)
      end

      def groups
        @user.groups.map(&:name)
      end

      def projects
        ProjectsDrop.new @user.memberships.map(&:project).flatten.select(&:visible?).uniq
      end

      def custom_field_values
        @user.custom_field_values
      end         
      
    end
  end
end
