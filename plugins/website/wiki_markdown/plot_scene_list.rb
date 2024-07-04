module AresMUSH
  module Website
    class PlotSceneListMarkdownExtension
      def self.regex
        /\[\[plotscenelist ([^\]]*)\]\]/i
      end

      def self.parse(matches)
        input = matches[1]
        return "" if !input

        direction = ""
        plot_id = nil
        char_name = nil

        options = input.split(' ')
        options.each do |opt|
          option_name = opt.before('=') || ""
          option_value = opt.after('=') || ""

          case option_name.downcase
          when "plot"
            plot_id = option_value
          when "char"
            char_name = option_value
          when 'ascending', 'descending'
            direction = option_name.strip
          end
        end

        if (!plot_id)
          return "Must specify plot ID."
        end

        if (plot_id)
          plot = Plot[plot_id]
        end
        if (!plot)
          return "Plot not found."
        end

        char = nil
        if (char_name)
          char = Character.named(char_name)
          if (!char)
            return "Character not found."
          end
        end

        if (char)
          matches = plot.sorted_scenes.select { |s| s.participants.include?(char) }
        else
          matches = plot.sorted_scenes
        end

        Global.logger.debug("Plot scene list for plot=#{plot_id} char=#{char_name} matches=#{matches.count}")

        template = HandlebarsTemplate.new(File.join(AresMUSH.plugin_path, 'website', 'templates', 'scene_list.hbs'))

        if direction == 'descending'
          data = {
            "scenes" => matches.sort_by { |m| m.icdate || m.created_at }.map { |m|
              {
                id: m.id,
                title: m.date_title,
                summary: Website.format_markdown_for_html(m.summary),
                participant_names: m.participant_names
              }
            }.reverse
          }
        else
          data = {
            "scenes" => matches.sort_by { |m| m.icdate || m.created_at }.map { |m|
              {
                id: m.id,
                title: m.date_title,
                summary: Website.format_markdown_for_html(m.summary),
                participant_names: m.participant_names
              }
            }
          }
        end

        template.render(data)
      end
    end
  end
end
