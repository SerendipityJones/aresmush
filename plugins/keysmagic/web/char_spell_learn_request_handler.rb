module AresMUSH
  module KeysMagic
    class CharSpellLearnRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor
        spell = request.args[:spell]
        category = request.args[:category]

        if (!char)
          return []
        end

        #first we check if they're still okay to learn it, else error
        if KeysMagic.has_spell?(char.name, spell)
          return { error: t('keysmagic.you_know_spell', :spell => spell) }
        end

        unless KeysMagic.can_learn?(char, category)
          return { error: t('keysmagic.you_cannot_learn', :spell => spell, :category => category) }
        end

        error = Website.check_login(request, true)
        return error if error

        #then we let them learn it
        ClassTargetFinder.with_a_character(char.name, Character, char) do |model|
          if model.spells.nil?
            model.update(spells: {})
          end
          charspells = model.spells
          if charspells[category].nil?
            charspells[category] = []
          end
          (charspells[category] ||= []) << spell
          model.update(spells: charspells)
          pronoun = Demographics.possessive_pronoun(model)
          KeysMagic.create_spell_job(model, spell, category, pronoun, 'add')
         end
        #then we return the updated availability information
        #return KeysMagic.learnableSpells(char)
      end
    end
  end
end
