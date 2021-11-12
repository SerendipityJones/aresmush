module AresMUSH
  module KeysMagic
    class SpellsAllTemplate < ErbTemplateRenderer

      attr_accessor :client

      def initialize(client)
        @client = client
        super File.dirname(__FILE__) + "/spells.erb"
        @magic_list = KeysMagic.catlist
      end

      def header
        return "All Spells"
      end

      def categories
        return @magic_list
      end

      def spells(category)
        spellList = Array.new
        KeysMagic.category_spells(category).each_with_index do |s, i|
          spellList << format_spell(s, i)
        end
        return spellList
      end

      def format_spell(s, i)
        name = FS3Skills.special_names.has_key?(s) ? "%x179#{FS3Skills.special_names[s]}:%xn" : "%x179#{s}:%xn"
        desc = KeysMagic.spells[s]["desc"]["short"]
        "#{left(name, 19)} #{left(desc, 58)}"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end
    end
  end
end
