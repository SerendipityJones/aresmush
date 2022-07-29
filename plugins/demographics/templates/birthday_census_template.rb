module AresMUSH
  module Demographics
    class BirthdayCensusTemplate < ErbTemplateRenderer

      attr_accessor :paginator

      def initialize(paginator)
        @paginator = paginator
        super File.dirname(__FILE__) + "/birthday_census.erb"
      end

      def format_month(char)
        left(char.birthdate.strftime("%B"), month_width)
      end

      def format_day(char)
        left(char.birthdate.strftime("%-d"), day_width)
      end

      def month_width; 15; end
      def day_width; 3; end
    end
  end
end
