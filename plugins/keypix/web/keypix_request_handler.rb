module AresMUSH
  module Keypix
    class KeypixRequestHandler

      def handle(request)

        enactor = request.enactor

        error = Website.check_login(request, true)
        return error if error

        keys = Global.read_config("keypix", "keys")

    		colours =  []
    		materials = []
    		motifs = []
    		styles = []

    		keys.each {|k, data| colours = colours.union(Array(data['colour'])).sort!}
    		keys.each {|k, data| materials = materials.union(Array(data['material'])).sort!}
    		keys.each {|k, data| motifs = motifs.union(Array(data['motif'])).sort!}
    		keys.each {|k, data| styles = styles.union(Array(data['style'])).sort!}

        keys.each {|k, data| Array(data['colour']).sort!}
        keys.each {|k, data| Array(data['material']).sort!}
        keys.each {|k, data| Array(data['motif']).sort!}
        keys.each {|k, data| Array(data['style']).sort!}

        {
          keys: keys,
    		  colours: colours,
    		  materials: materials,
    		  motifs: motifs,
    		  styles: styles
        }

      end
    end
  end
end
