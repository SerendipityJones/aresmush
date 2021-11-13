module AresMUSH
   module KeysMagic
    class SpellcountCmd
      include CommandHandler

      attr_accessor :name

      def parse_args
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor_name
      end

      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          spells = Hash.new
          result = ""
          KeysMagic.catlist.each_with_index do |cat, i|
            spells[cat] = {}
            if model.spells.nil? || model.spells.empty?
              spells[cat]["known"] = 0
              spells[cat]["available"] = 0
            else
              spells[cat]["known"] = model.spells[cat].nil? ? 0 : model.spells[cat].length
              spells[cat]["allowed"] = KeysMagic.current_cap(model, cat)
              spells[cat]["available"] = spells[cat]["allowed"] - spells[cat]["known"]
            end
            result += "\n" if i > 0
            result += "     %x179#{Array(cat).join.concat(':').ljust(10)}%xn #{spells[cat]["known"].to_s.gsub(/\b0\b/,"No")} spell#{spells[cat]["known"] == 1 ? '' : 's'} known; #{spells[cat]["available"].to_s.gsub(/\b0\b/,"no")} slot#{spells[cat]["available"] == 1 ? '' : 's'} open."
          end
		  msg = <<-SPELLS.chomp
Spell Count for #{model.name}:

#{result}
		  SPELLS
          template = BorderedDisplayTemplate.new msg
          client.emit template.render
        end
      end
    end
  end
end
