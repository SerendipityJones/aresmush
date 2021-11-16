module AresMUSH
  module KeysMagic
    class SpellsTemplate < ErbTemplateRenderer

      attr_accessor :char, :client

      def initialize(char, client)
        @char = char
        @client = client
        super File.dirname(__FILE__) + "/spells.erb"
        @magic_list = KeysMagic.catlist
      end

      def header
        return "#{@char.name}'s Spells"
      end

      def categories
        catList = Array.new
        @magic_list.each do |cat|
          unless @char.spells[cat].nil?
            catList << cat
          end
        end
        return catList
      end

      def spells(category)
        spellList = Array.new
        unless @char.spells[category].nil?
          knownList = KeysMagic.char_spells(@char.name)[category].sort
        end
        knownList.each_with_index do |s, i|
          spellList << format_spell(s, i)
        end
        return spellList
      end

      def format_spell(s, i)
        spell = s[1]
        name = FS3Skills.special_names.has_key?(s[0]) ? "%x179#{FS3Skills.special_names[s[0]]}:%xn" : "%x179#{s[0]}:%xn"
        roll = spell["roll"]
        vs_roll = spell["offense"] ? "#{spell["offense"]} vs #{spell["defense"]}" : ""
        fs3 = spell["fs3"] ? "#{spell["fs3"]}" : "No special attack"
        special = spell["special"] ? spell["special"].split(";").join(";\n" << " "*25) : nil
        if s[0] == "Heal" && !special.nil?
          cap = FS3Skills.find_ability(@char, "Life").rating
          times = case cap
          when 1
            "once"
          when 2
            "twice"
          when 3
            "thrice"
          else
            cap.to_s << " times"
          end
          special.gsub!("one time per Life dot", "#{times}")
        end
        result = "#{left(name, 19)} Roll: #{left(roll, 19)}%x179|%xn FS3: #{left(fs3, 18)}"
        if spell["anomaly"]
          result = "#{left(name, 19)} Roll: #{left(roll, 44)}"
        end
        if spell["offense"]
          result += "\n#{left(" ",20)}vs:   #{left(vs_roll, 53)}"
        end
        if spell["special"]
          result += "\n#{left(" ",20)}Note: #{special}"
        end
        if i > 0
          result.prepend("#{"%x179·%xn"*78}\n")
        end
        return result
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end
    end
  end
end
