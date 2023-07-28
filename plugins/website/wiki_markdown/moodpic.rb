module AresMUSH
  module Website
    class MoodpicMarkdownExtension
	  include CommandHandler

      def self.regex
        /\[\[moodpic ([^\]]*)\]\]/i
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

        pix = Global.read_config("wikipix", "moodpix")

	      key = pix.keys.sample 
        source = pix[key][0]
		    caption = pix[key][1]
		    description = pix[key][2]

        template = HandlebarsTemplate.new(File.join(AresMUSH.plugin_path, 'website', 'templates', 'moodpic.hbs'))

        data = {
          "source" => source,
		      "align" => align,
		      "caption" => caption,
		      "description" => description
        }

        template.render(data)
      end
    end
  end
end
