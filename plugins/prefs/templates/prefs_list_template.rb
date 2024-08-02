module AresMUSH
  module Prefs
    class PrefsListTemplate < ErbTemplateRenderer

      attr_accessor :char

      def initialize(char)
        super File.dirname(__FILE__) + "/prefs_list.erb"
      end

      def prefs
        Prefs.preferences
      end

      def desc(cat, key)
        return prefs[cat][key]
      end

    end
  end
end  