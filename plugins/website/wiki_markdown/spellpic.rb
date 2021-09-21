module AresMUSH
  module Website
    class SpellpicMarkdownExtension
	  include CommandHandler

      def self.regex
        /\[\[spellpic ([^\]]*)\]\]/i
      end

       def self.parse(matches)
        input = matches[1]
        return "" if !input
        
        align = ""
        options = input.split(' ')
        options.each do |opt|
          option_name = opt.before('=') || ""
          option_value = opt.after('=') || ""
        
          case option_name.downcase.strip
          when 'center', 'left', 'right'
            align = opt.strip
         end
        end

        pix = Global.read_config("wikipix", "spellpix")
        source="#{pix.sample}"

        template = HandlebarsTemplate.new(File.join(AresMUSH.plugin_path, 'website', 'templates', 'spellpic.hbs'))
        
        data = {
          "source" => source,
		  "align" => align
        }
        
        template.render(data)        
      end
    end
  end
end
