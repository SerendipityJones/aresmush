module AresMUSH
  module Prefs
    class PrefCmd
      include CommandHandler
                
      attr_accessor :pref
            
      def parse_args
        self.pref = cmd.args
      end
      
      def handle
        if (!self.pref)
          client.emit_failure t('prefs.no_pref_given')
          return
        elsif (!Prefs.valid_key(self.pref))
          client.emit_failure t('prefs.pref_invalid', :error => self.pref)
        else   
          template = PrefTemplate.new(self.pref)
          client.emit template.render
        end    
      end
    end
  end
end
