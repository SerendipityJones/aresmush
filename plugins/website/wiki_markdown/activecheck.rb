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
        
        Character.find_one_by_name(charname).select { |c| c.idle_state != nil && c.is_approved?} ? "active" : "inactive"
      
      end
    end
  end
end
