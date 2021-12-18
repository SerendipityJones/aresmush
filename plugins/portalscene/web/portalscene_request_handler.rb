module AresMUSH
  module Portalscene
    class PortalsceneRequestHandler

      def handle(request)

        enactor = request.enactor

        error = Website.check_login(request, true)
        return error if error

        locations = Array.new
        actions = Array.new
        things = Array.new
        cues = Array.new
        ymlLocations = Global.read_config("portalscene", "location")
        ymlLocations.each do |x|
          locations << Website.format_markdown_for_html(x.to_s)
        end
        ymlActions = Global.read_config("portalscene", "action").each do |x|
          actions << Website.format_markdown_for_html(x.to_s)
        end
        ymlThings = Global.read_config("portalscene", "thing").each do |x|
          things << Website.format_markdown_for_html(x.to_s)
        end
        ymlCues = Global.read_config("portalscene", "cue").each do |x|
          cues << Website.format_markdown_for_html(x.to_s)
        end

        {
          location: locations,
          action: actions,
          thing: things,
          cue: cues,
          newLocation: "#{locations.sample}",
          newAction: "#{actions.sample}",
          newThing: "#{things.sample}",
          newCue: "#{cues.sample}"
        }

      end
    end
  end
end
