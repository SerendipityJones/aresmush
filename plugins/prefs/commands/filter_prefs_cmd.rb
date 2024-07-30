module AresMUSH
  module Prefs
    class FilterPrefsCmd
      include CommandHandler
                
      attr_accessor :search
            
      def parse_args
        self.search = trim_arg(cmd.args)
      end
      
      def required_args
        [ self.search ]
      end
      
      def handle
        chars = Chargen.approved_chars.select { |c| c.rp_prefs =~ /#{self.search}/i }.sort_by { |c| c.name }
        template = PrefsFilterTemplate.new(self.search, chars)
        client.emit template.render
      end
    end
  end
end
