module AresMUSH
  module Prefs
    class PrefTemplate < ErbTemplateRenderer
            
      attr_accessor :pref
      
      def initialize(pref)
        @pref = pref
        super File.dirname(__FILE__) + "/pref.erb"
      end
      
      def prefs
        Prefs.sort_prefs || {}
      end

      def pref
        @pref
      end

      def cat
        prefs[:pref_list].each do |cat, prefs|
          if prefs.key?(pref)
            return cat
          end
        end  
      end

      def pref_name
        pref_list=Prefs.preferences
        return pref_list[cat][@pref]
      end

      def name_sorter(num)
        the_names = ''
        prefs[:pref_sort][cat][@pref][num].each do |name|
          if (name == prefs[:pref_sort][cat][@pref][num].last)
            the_names += "#{name}"
          else
            the_names += "#{name}, "
          end  
        end  
        return the_names
      end
      
      def green_names
        name_sorter(3)
      end
      
      def yellow_names
        name_sorter(2)
      end
      
      def red_names
        name_sorter(1)
      end
      
    end
  end
end
