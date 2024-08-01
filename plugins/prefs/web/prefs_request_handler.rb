module AresMUSH
  module Prefs
    class PrefsRequestHandler
      def handle(request)
        
        Prefs.sort_prefs
        
      end
    end
  end
end