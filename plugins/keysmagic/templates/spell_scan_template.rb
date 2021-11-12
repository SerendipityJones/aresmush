module AresMUSH
  module KeysMagic
    class SpellScanTemplate < ErbTemplateRenderer

      attr_accessor :client, :topic, :type

      def initialize(client, topic, type)
        @client = client
        @topic = topic
        @type = type
        super File.dirname(__FILE__) + "/spells.erb"
        @magic_list = KeysMagic.catlist
      end

      def header
        head = "Spell Scan"
        unless @topic == "all"
          head += ": #{@topic}"
        end
        return head
      end

      def categories
        catList = Array.new
        if @type == "all"
            catList = @magic_list
        elsif @type == "category"
          catList << @topic
        else
          KeysMagic.get_category(@topic).each do |cat|
            catList << cat
          end
        end
        return catList
      end

      def spells(category)
        spellList = Array.new
        KeysMagic.spell_demographics[category].each_with_index do |s, i|
          if (@type != "spell" || (@type == "spell" && @topic == s[0]))
            spellList << format_spell(s, i)
          end
        end
        return spellList
      end

      def format_spell(s, i)
        name = FS3Skills.special_names.has_key?(s[0]) ? "%x179#{FS3Skills.special_names[s[0]]}:%xn" : "%x179#{s[0]}:%xn"
        chars = s[1].join(', ')
        "#{left(name, 19)} #{left(chars, 58)}"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end
    end
  end
end
