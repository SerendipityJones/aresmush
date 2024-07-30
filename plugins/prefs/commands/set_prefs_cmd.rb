module AresMUSH
  module Prefs
    class SetPrefsCmd
      include CommandHandler
                
      attr_accessor :prefs, :name
            
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
          
        if (args.arg2)
          self.name = titlecase_arg(args.arg1)
          self.prefs = trim_arg(args.arg2)
        else
          self.name = enactor_name
          self.prefs = trim_arg(args.arg1)
        end
      end

      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          
          if (!Prefs.can_edit_prefs?(enactor, model))
            client.emit_failure t('dispatcher.not_allowed')
            return
          end
          
          model.update(rp_prefs: self.prefs)
          client.emit_success t('prefs.pref_set')
        end
      end
    end
  end
end
