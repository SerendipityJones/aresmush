module AresMUSH
  module Website
    class SceneListMarkdownExtension
      def self.regex
        /\[\[scenelist ([^\]]*)\]\]/i
      end

      def self.parse(matches)
        input = matches[1]
        return "" if !input

        direction = ""
        options = input.split(' ')
        options.each do |opt|
          case opt.downcase.strip
            when 'ascending', 'descending'
              direction = opt.strip
              options.delete(direction)
              input = options.join(" ")
          end
        end

        helper = TagMatchHelper.new(input)

        matches = Scene.shared_scenes.select { |p|
          ((p.content_tags & helper.or_tags).any? &&
          (p.content_tags & helper.exclude_tags).empty?) &&
          (helper.required_tags & p.tags == helper.required_tags)
        }

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
