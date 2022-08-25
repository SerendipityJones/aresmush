module AresMUSH
  module KeysMagic
    class CharSpellListRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor

        if (!char)
          return []
        end

        alts = AresCentral.play_screen_alts(char)

        spellList = {}
        alts.each do |alt|
          spellList[alt.name] = {'opposed' => [], 'unopposed' => []}
          alt.spells.each do |category, spells|
            spells.each do |spell|
              unless (KeysMagic.spells[spell]['noroll'] || (KeysMagic.spells[spell]["offense"] && KeysMagic.spells[spell]["offense"]["only"]))
                spellList[alt.name]['unopposed'] << spell
              end
              if (KeysMagic.spells[spell]["offense"])
                spellList[alt.name]['opposed'] << spell
              end
            end
          end
          spellList[alt.name]['unopposed'].sort!
          spellList[alt.name]['opposed'].sort!
        end

        error = Website.check_login(request, true)
        return error if error

        return spellList
      end
    end
  end
end
