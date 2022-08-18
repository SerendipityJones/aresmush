module AresMUSH
  module KeysMagic
    class CharSpellNoteRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor
        spell = request.args[:spell]
        note = request.args[:note]

        if (!char)
          return []
        end

        ClassTargetFinder.with_a_character(char.name, Character, char) do |model|
          if model.spells.nil?
            model.update(spells: {})
          end
          Global.logger.info "#{note}"
          charspells = model.spells
          also = ""
          if (KeysMagic.has_spell?(char.name, spell))
            if (KeysMagic.spell_info(spell)["note"])
              if (KeysMagic.spell_info(spell)["confirm"] && note)
                unless Character.find_one_by_name(note)
                  return { error: t('keysmagic.not_a_character', :name => note) }
                else
                  note = Character.find_one_by_name(note).name
                end
                unless (KeysMagic.has_spell?(note, spell))
                  return { error: t('keysmagic.they_do_not_know_spell',:name => note, :spell => spell) }
                else
                  unless KeysMagic.is_a_match?(char.name, note, spell)
                    also = " Your partner will need to set the corresponding note before it shows up."
                  else
                    also = " You've both set your notes and it should now be visible."
                  end
                end
              end
              if model.spellnotes.nil?
                model.update(spellnotes: {})
              end
              newnotes = model.spellnotes
              newnotes[spell] = note
              model.update(spellnotes: newnotes)
              if note == ""
                newnotes = model.spellnotes
                newnotes.delete(spell)
                model.update(spellnotes: newnotes)
                return { success: t('keysmagic.spell_note_cleared', :spell => spell) }
              else
                return { success: t('keysmagic.spell_note_set', :spell => spell, :content => note, :also => also) }
              end
            else
              return { error: t('keysmagic.spell_does_not_take_note', :spell => spell) }
            end
          else
            return { error: t('keysmagic.you_do_not_know_spell', :spell => spell) }
          end
        end
      end
    end
  end
end
