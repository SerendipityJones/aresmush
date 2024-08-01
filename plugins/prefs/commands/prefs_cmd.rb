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
          prefs = Prefs.build_profile_prefs(model)
          template = PrefsTemplate.new(model)
          client.emit template.render
        end
      end
    end
  end
end
