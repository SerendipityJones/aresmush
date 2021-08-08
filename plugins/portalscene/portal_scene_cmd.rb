module AresMUSH
  module Portalscene
    class PortalsceneSceneCmd
    # shield/off <shield>
      include CommandHandler
	  
	  def handle
	    location = Global.read_config("portalscene", "location")
	    action = Global.read_config("portalscene", "action")
	    thing = Global.read_config("portalscene", "thing")
	    cue = Global.read_config("portalscene", "cue")
	  
	    template = BorderedDisplayTemplate.new "Your destination could be #{location.sample} \n\n#{action.sample} \n\nAn involved item or trinket could be #{thing.sample}. Consider using a theme of #{cue.sample}", "Portal Scene Prompt"

        client.emit template.render
      end
 
    end
  end
end