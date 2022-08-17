module AresMUSH
  module KeysMagic
    class CharSpellLearnableRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor

        if (!char)
          return []
        end

        error = Website.check_login(request, true)
        return error if error

        return KeysMagic.learnableSpells(char)
      end

    end
  end
end
