module AresMUSH
  module Prefs
    class SetPrefCmd
      include CommandHandler
                
      attr_accessor :pref, :level, :format
            
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)          
        self.pref = trim_arg(args.arg1)
        self.format = trim_arg(args.arg2)
        self.level = "0"
        case self.format
        when "1","R","r","Red","red"
          self.level = "1";
        when "2","Y","y","Yellow","yellow"
          self.level = "2";
        when "3","G","g","Green","green"
          self.level = "3";
        end  
      end

      def handle
        if (self.level == "0")
          client.emit_failure t('prefs.level_invalid', :error => self.format)  
          return
        end  
        ClassTargetFinder.with_a_character(enactor_name, client, enactor) do |model|
          pref_list = Prefs.preferences
          the_cat = ''
          valid = false
          pref_list.each do |cat, prefs|
            if (prefs.key?(self.pref))
              valid = true
              if (valid)  
                old_prefs = model.rp_prefs
                changed_pref = {self.pref => self.level}
                new_prefs = old_prefs[cat].merge!(changed_pref)
                new_prefs = old_prefs.merge(new_prefs)
                model.update(rp_prefs: new_prefs)
                client.emit_success t('prefs.pref_set', :pref => self.pref, :level => self.format)
                break 
              end  
            end 
          end           
          unless (valid)  
            client.emit_failure t('prefs.pref_invalid', :error => self.pref)
          end    
        end
      end

    end
  end
end
