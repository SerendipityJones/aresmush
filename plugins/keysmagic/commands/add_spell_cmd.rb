module AresMUSH

  module KeysMagic
    class AddSpellCmd
      include CommandHandler

      attr_accessor :spell, :category, :target

      def parse_args
        @killcmd = false
        if (cmd.args =~ /=/ && cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
          self.target = trim_arg(args.arg1)
          self.spell = KeysMagic.is_spell?(args.arg2)
          self.category = Array(titlecase_arg(args.arg3))
        elsif (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target = trim_arg(args.arg1)
          self.spell = KeysMagic.is_spell?(args.arg2)
        elsif (cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_slash_arg2)
          self.target = enactor_name
          self.spell = KeysMagic.is_spell?(args.arg1)
          self.category = Array(titlecase_arg(args.arg2))
          unless KeysMagic.is_category?(self.category)
            @killcmd = true
          end
        else
          self.target = enactor_name
          self.spell = KeysMagic.is_spell?(cmd.args)
        end
        if self.target.downcase == enactor_name.downcase
          self.target = enactor_name
        end
        unless (self.category)
          if self.spell
            self.category = KeysMagic.get_category(self.spell)
            return
          else
            self.category = "FAILED"
          end
        end
      end

      def required_args
        [ self.target, self.spell, self.category ]
      end

      def check_can_set
        return nil if enactor_name == self.target
        return nil if FS3Skills.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end

      def handle
        if (@killcmd)
            client.emit_failure t('keysmagic.slash_for_equals')
            return
        end
        if (self.category == "FAILED")
          client.emit_failure t('keysmagic.no_such_spell')
          return
        end
        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          ownspell = self.target == enactor.name ? true : false
          if (self.category.length > 1)
            client.emit_failure t('keysmagic.too_many_aspects', :spell => self.spell)
            return
          end
          unless (KeysMagic.spells[spell]['category'].include? self.category[0])
            client.emit_failure t('keysmagic.does_not_exist', :spell => self.spell, :category => self.category[0])
            return
          end
          if model.spells.nil?
            model.update(spells: {})
          end
          charspells = model.spells
          included = false
          charspells.each do |cat, spells|
            if spells.include? self.spell
              included = true
            end
          end
          if (charspells && included)
            if (ownspell)
              client.emit_failure t('keysmagic.you_know_spell', :spell => self.spell)
            else
              client.emit_failure t('keysmagic.they_know_spell', :name => model.name, :spell => self.spell)
            end
            return
          end
          unless (can_learn?(model, self.category[0]))
            if (ownspell)
              client.emit_failure t('keysmagic.you_cannot_learn', :spell => self.spell, :category => self.category[0])
            else
              client.emit_failure t('keysmagic.they_cannot_learn', :name => model.name, :spell => self.spell, :category => self.category[0])
            end
            return
          end
          (charspells[self.category[0]] ||= []) << self.spell
          model.update(spells: charspells)
          if (ownspell)
            pronoun = Demographics.possessive_pronoun(model)
            KeysMagic.create_spell_job(model,self.spell,self.category[0],pronoun,'add')
            client.emit_success t('keysmagic.your_spell_added', :spell => self.spell, :category => self.category[0])
          else
            client.emit_success t('keysmagic.their_spell_added', :name => model.name, :spell => self.spell, :category => self.category[0])
          end
        end
      end

      def can_learn?(char, category)
        spellcap = KeysMagic.current_cap(char, category)
        spellsknown = char.spells[category].nil? ? 0 : char.spells[category].length
        if (spellsknown < spellcap)
          true
        end
      end

    end
  end
end
