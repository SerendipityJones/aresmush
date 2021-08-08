module AresMUSH
  module Custom
    class CheckXPCmd
      include CommandHandler

      attr_accessor :name

      def parse_args
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor_name
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          targettext = model.name == enactor_name ? 'You have ' : model.name + ' has '
          currentxp = model.xp.floor()
          max_xp = Global.read_config("fs3skills", "max_xp_hoard")
          cap_note = ""
          if currentxp==max_xp
            cap_note = " That's capped!"
          elsif currentxp>max_xp-2
            cap_note = " That's nearly at cap!"
          end
          expressxp = currentxp==0 ? 'no' : currentxp.to_s
          client.emit targettext + expressxp + " available XP." + cap_note
        end
      end
    end
  end
end
