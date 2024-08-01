module AresMUSH
  module Prefs
    class PrefsNotesCmd
      include CommandHandler

      attr_accessor :notes

      def parse_args
        self.notes = trim_arg(cmd.args)
      end

      def handle
        if (self.notes == nil)
          enactor.update(rp_notes: nil)
          client.emit_success t('prefs.notes_cleared')  
        else  
          enactor.update(rp_notes: self.notes)  
          client.emit_success t('prefs.notes_set')          
        end
      end

    end
  end
end
