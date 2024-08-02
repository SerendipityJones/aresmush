module AresMUSH
  module Prefs
    class PrefsTemplate < ErbTemplateRenderer
            
      attr_accessor :char
      
      def initialize(char)
        @char = char
        super File.dirname(__FILE__) + "/prefs.erb"
      end
      
      def name
        @char.name
      end
      
      def prefs
        @char.rp_prefs || {}
      end

      def hasnotes
        @char.rp_notes || nil
      end

      def notes
        formatter = MarkdownFormatter.new
        formatter.to_mush(@char.rp_notes)
      end
      
      def desc(cat, key)
        pref_list=Prefs.preferences
        return pref_list[cat][key]
      end
      
      def setting(cat, key)
        setting = prefs[cat][key]
        case setting
        when "3"
          return "%xgG%xn"
        when "1"
          return "%xrR%xn"
        else
          return "%xyY%xn"
        end
      end
    end
  end
end
