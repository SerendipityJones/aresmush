module AresMUSH

  module KeysMagic
    class RemoveSpellCmd
      include CommandHandler

      attr_accessor :spell, :target, :category

      def parse_args
        if (cmd.args =~ /=/ && cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
          self.target = trim_arg(args.arg1)
          self.spell = KeysMagic.is_spell?(args.arg2)
          self.category = titlecase_arg(args.arg3)
          self.category = KeysMagic.is_category?(self.category)
        elsif (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target = trim_arg(args.arg1)
          self.spell = titlecase_arg(args.arg2)
          self.category = false
        end
      end

      def required_args
        [ self.target, self.spell, self.category ]
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
          category = self.category ? KeysMagic.is_category?(self.category) : KeysMagic.get_category(is_spell)
          category = Array(category) if category
          if (category)
            if (category.length == 1)
              if (charspells[category[0]].find {|spell| spell.include?(is_spell)})
                known = true
              end
            else
              client.emit_failure t('keysmagic.too_many_aspects', :spell => self.spell)
              return
            end
          else
            client.emit_failure t('keysmagic.no_such_spell')
            return
          end
          unless known
            client.emit_failure t('keysmagic.does_not_know_spell', :name => name, :spell => self.spell)
            return
          else
            charspells[category[0]].delete(is_spell)
            model.update(spells: charspells)
            client.emit_success t('keysmagic.their_spell_removed', :name => name, :spell => self.spell, :category => category)
          end
        end
      end

    end
  end
end
