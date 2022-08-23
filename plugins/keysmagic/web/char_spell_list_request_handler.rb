module AresMUSH
  module KeysMagic
    class CharSpellListRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor

        if (!char)
          return []
        end

        spellList = {'opposed' => [], 'unopposed' => []}
        char.spells.each do |category, spells|
          spells.each do |spell|
            unless (KeysMagic.spells[spell]['noroll'] || (KeysMagic.spells[spell]["offense"] && KeysMagic.spells[spell]["offense"]["only"]))
              spellList['unopposed'] << spell
            end
            if (KeysMagic.spells[spell]["offense"])
              spellList['opposed'] << spell
            end
          end
        end
        spellList['unopposed'].sort!
        spellList['opposed'].sort!

        error = Website.check_login(request, true)
        return error if error

        return spellList
      end
    end
  end
end
