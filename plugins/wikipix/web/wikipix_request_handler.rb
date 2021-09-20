module AresMUSH
  module Portalscene
    class PortalsceneRequestHandler

      def handle(request)

        enactor = request.enactor

        error = Website.check_login(request, true)
        return error if error
        
        moodpic = Global.read_config("wikipix", "moodpix")
        spellpic = Global.read_config("wikipix", "spellpix")
        {
          moodpic: "#{moodpix.sample}",
          spellpic: "#{spellpix.sample}",
        }
        
      end
    end
  end
end