module AresMUSH

  module KeysMagic
    class RemoveSpellCmd
      include CommandHandler

      attr_accessor :spell, :target

      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target = trim_arg(args.arg1)
          self.spell = titlecase_arg(args.arg2)
        end
      end

      def required_args
        [ self.target, self.spell ]
      end

      def check_can_set
        return nil if FS3Skills.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end

      def handle
        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          charspells = model.spells
          name = model.name
          known = false
          is_spell = KeysMagic.is_spell?(self.spell)
          if charspells.find {|cat, spell| spell.include?(is_spell)}
            known = true
          end
          Global.logger.info "known? #{known}"
          unless known
            client.emit_failure t('keysmagic.does_not_know_spell', :name => name, :spell => self.spell)
            return
          else
            category = KeysMagic.spells[spell]['category']
            charspells[category[0]].delete(spell)
            model.update(spells: charspells)
            client.emit_success t('keysmagic.their_spell_removed', :name => name, :spell => self.spell)
          end
        end
      end

    end
  end
end
