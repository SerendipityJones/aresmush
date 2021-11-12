module AresMUSH
  module KeysMagic
    class CharSpellsRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor

        #  Global.logger.debug "Spells: #{char.spells}"

        if (!char)
          return []
        end

        error = Website.check_login(request, true)
        return error if error

        {
          myspells: char.spells
        }
      end
    end
  end
end
