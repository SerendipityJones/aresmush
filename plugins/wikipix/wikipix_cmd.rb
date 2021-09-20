module AresMUSH
  module Portalscene
    class PortalsceneSceneCmd
    # shield/off <shield>
      include CommandHandler
	  
	  def handle
	    moodpic = Global.read_config("wikipix", "moodpix")
		spellpic = Global.read_config("wikipix", "spellpix")
      end
 
    end
  end
end