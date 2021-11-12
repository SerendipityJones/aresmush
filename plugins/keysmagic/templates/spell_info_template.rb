module AresMUSH
  module KeysMagic
    class SpellInfoTemplate < ErbTemplateRenderer

      attr_accessor :spell

      def initialize(spell)
        @spell = spell
        super File.dirname(__FILE__) + "/spellinfo.erb"
      end

      def header
        return "Spell Info: #{@spell}"
      end

      def data
        category = KeysMagic.get_category(@spell).join(', ')
        info = KeysMagic.spell_info(@spell)
        roll = info["roll"]
        vs = "#{info["offense"]} vs #{info["defense"]}"
        fs3 = info["fs3"]
        result = "Roll: #{left(roll,42)} Aspect: #{left(category,22)} "
        if info["offense"] && fs3
          result += "\nvs:   #{left(vs,42)} FS3:    #{left(fs3,22)}"
        elsif info["offense"]
          result += "\nvs:   #{left(vs,72)}"
        elsif info["fs3"]
          result += "\n#{left(' ',48)} FS3:  #{left(fs3,22)}"
        end
        return result
      end

      def text
        info = KeysMagic.spells[spell]["desc"]["full"].gsub(/\/\//, "*").gsub('[[div class="spellrolls"]]', "#{"%x179·%xn"*78}\n").gsub(/^\[\[\/div\]\]/, "#{"%x179·%xn"*78}").gsub(/\[\[div class\=\"result\"\]\](.+?)\[\[\/div\]\]/){left($1<<':',22)}.gsub(/\[\[div class\=\"outcome\"\]\](.+)\[\[\/div\]\]/){wrap($1,56,22)<<"\n"}.gsub(/\[\[\[.+?\|(.+)\]\]\]/){$1}
      end

      def format_spell(s, i)
        name = FS3Skills.special_names.has_key?(s) ? "%x179#{FS3Skills.special_names[s]}:%xn" : "%x179#{s}:%xn"
        desc = KeysMagic.spells[s]["desc"]["short"]
        "#{left(name, 19)} #{left(desc, 58)}"
      end

    end
  end
end
