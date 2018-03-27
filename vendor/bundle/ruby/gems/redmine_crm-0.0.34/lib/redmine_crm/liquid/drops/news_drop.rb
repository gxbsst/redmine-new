module RedmineCrm
  module Liquid
    class NewssDrop < ::Liquid::Drop

      def self.default_drop
        self.new News.visible.order("#{News.table_name}.created_on")
      end

      def initialize(newss)
        @newss = newss
      end

      def before_method(id)
        news = @newss.where(:id => id).first || News.new
        NewsDrop.new news
      end

      def last
        NewsDrop.new News.last
      end

      def all
        @all ||= @newss.map do |news|
          NewsDrop.new news
        end
      end

      def each(&block)
        all.each(&block)
      end

      def size
        @newss.size
      end
    end

    class NewsDrop < ::Liquid::Drop
      delegate :id, :title, :summary, :description, :visible?, :commentable?, :to => :@news

      def initialize(news)
        @news = news
      end

      def author
        UserDrop.new @news.author
      end

      def custom_field_values
        @news.custom_field_values
      end   
            
    end
  end
end
