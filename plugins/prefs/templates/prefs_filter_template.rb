module AresMUSH
  module Prefs
    class PrefsFilterTemplate < ErbTemplateRenderer
            
      attr_accessor :search, :chars
      
      def initialize(search, chars)
        @search = search
        @chars = chars
        super File.dirname(__FILE__) + "/prefs_filter.erb"
      end
    end
  end
end
