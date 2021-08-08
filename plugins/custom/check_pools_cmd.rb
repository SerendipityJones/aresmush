module AresMUSH
  module Custom
    class CheckPoolsCmd
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor_name
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          targettext = model.name == enactor_name ? 'You have ' : model.name + ' has '
          currentluck = model.luck.floor()
          currentxp = model.xp 
          max_luck = Global.read_config("fs3skills", "max_luck")
          max_xp = Global.read_config("fs3skills", "max_xp_hoard")
          luck_note = "" 
          xp_note = ""
          if currentluck==max_luck
            luck_note = " (that's capped!)"
          elsif currentluck>max_luck-2
            luck_note = " (that's nearly at cap!)"
          end
          if currentxp==max_xp
            xp_note = " (that's capped!)"
          elsif currentxp>max_xp-2
            xp_note = " (that's nearly at cap!)"
          end
          pluralize = currentluck==1 ? '' : 's'
          expressluck = currentluck==0 ? 'no' : currentluck.to_s
          client.emit targettext + expressluck + " Luck point" + pluralize + luck_note + " and " + currentxp.to_s + " XP" + xp_note + "."
        end
      end
    end
  end
end
