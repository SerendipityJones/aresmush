module AresMUSH
  module Custom
    class CheckLuckCmd
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor_name
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          targettext = model.name == enactor_name ? 'You have ' : model.name + ' has '
          currentluck = model.luck.floor()
          max_luck = Global.read_config("fs3skills", "max_luck")
          cap_note = ""
          if currentluck==max_luck
            cap_note = " That's capped!"
          elsif currentluck>max_luck-2
            cap_note = " That's nearly at cap!"
          end 
          pluralize = currentluck==1 ? '' : 's'
          expressluck = currentluck==0 ? 'no' : currentluck.to_s
          client.emit targettext + expressluck + " Luck point" + pluralize + "." + cap_note
        end
      end
    end
  end
end
