module AresMUSH
  module Website
    class ActiveCheckMarkdownExtension
          include CommandHandler

      def self.regex
        /\[\[activecheck (\w*)\]\]/i
      end

       def self.parse(matches)
        input = matches[1]
        return "" if !input

        charname = input.downcase.strip

        char = Character.find_one_by_name(charname)

        return if char.nil?

        char.idle_state.nil? && char.is_approved? ? "active" : "inactive"

      end
    end
  end
end
