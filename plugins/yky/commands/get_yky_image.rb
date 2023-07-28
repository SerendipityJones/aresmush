module AresMUSH
    module Yky
  
        def self.get_yky_image
  
          ykylist = Global.read_config("wikipix", "called")

          yky = ykylist.keys.sample
  
          {
            source: ykylist["#{yky}"][0],
            caption: ykylist["#{yky}"][1]
          }
  
      end
    end
  end