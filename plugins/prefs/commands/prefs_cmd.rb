module AresMUSH
  module Prefs
    class PrefsCmd
      include CommandHandler
                
      attr_accessor :name
            
      def parse_args
        self.name = cmd.args || enactor_name
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          if (model.rp_prefs.blank?)
            client.emit_failure t('prefs.none_set', :name => model.name)
            return
          end
          formatter = MarkdownFormatter.new
          text = formatter.to_mush(model.rp_prefs)
          template = BorderedDisplayTemplate.new(text, t('prefs.prefs_title', :name => model.name))
          client.emit template.render
        end
      end
    end
  end
end
