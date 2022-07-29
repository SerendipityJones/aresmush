module AresMUSH

  module KeysMagic
    class SpellNoteCmd
      include CommandHandler

      attr_accessor :spell, :note, :target

      def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
          self.spell = KeysMagic.is_spell?(args.arg1)
          self.note = trim_arg(args.arg2)
          self.target = enactor_name
      end

      def required_args
        [ self.target, self.spell ]
      end

      def check_can_set
        return nil if enactor_name == self.target
        return nil if FS3Skills.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end

      def handle
        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          unless self.spell
            client.emit_failure t('keysmagic.no_such_spell')
            return
          end
          if model.spells.nil?
            model.update(spells: {})
          end
          charspells = model.spells
          also = ""
          if (KeysMagic.has_spell?(self.target, self.spell))
            if (KeysMagic.spell_info(self.spell)["note"])
              if (KeysMagic.spell_info(self.spell)["confirm"] && self.note)
                unless (KeysMagic.has_spell?(self.note, self.spell))
                  client.emit_failure t('keysmagic.they_do_not_know_spell',:name => self.note, :spell => self.spell)
                  return
                else
                  unless KeysMagic.is_a_match?(self.target, self.note, self.spell)
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
              newnotes[self.spell] = self.note
              model.update(spellnotes: newnotes)
              if self.note.nil?
                client.emit_success t('keysmagic.spell_note_cleared', :spell => self.spell)
                return
              else
                client.emit_success t('keysmagic.spell_note_set', :spell => self.spell, :content => self.note, :also => also)
                return
              end
            else
              client.emit_failure t('keysmagic.spell_does_not_take_note', :spell => self.spell)
              return
            end
          else
              client.emit_failure t('keysmagic.you_do_not_know_spell', :spell => self.spell)
              return
          end
        end
      end

    end
  end
end
