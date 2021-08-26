module AresMUSH
  module Portalscene
    class PortalsceneRequestHandler

      def handle(request)

        enactor = request.enactor

        error = Website.check_login(request, true)
        return error if error
        
        locations = Global.read_config("portalscene", "location")
        actions = Global.read_config("portalscene", "action")
        things = Global.read_config("portalscene", "thing")
        cues = Global.read_config("portalscene", "cue")

        {
          location: "#{locations.sample}",
          action: "#{actions.sample}",
          thing: "#{things.sample}",
          cue: "#{cues.sample}"
        }
        
      end
    end
  end
end