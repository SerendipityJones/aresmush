module AresMUSH

  module KeysMagic
    class OpposedCastCmd
      include CommandHandler

      attr_accessor :name1, :name2, :spell, :resist, :preposition, :private_roll

      def parse_args
        args = cmd.parse_args( /(?<name1>[^\/]+)\/?(?<str1>.+)? (?<preposition>vs|on) (?<name2>[^\/]+)\/?(?<str2>.+)?/ )
        self.spell = titlecase_arg(args.str1)
        self.resist = titlecase_arg(args.str2)
        self.name1 = titlecase_arg(args.name1)
        self.name2 = titlecase_arg(args.name2)
        self.preposition = args.preposition
        self.private_roll = cmd.switch_is?("private")
        Global.logger.info "#{args}"
      end

      def required_args
        [ self.name1, self.name2, self.preposition ]
      end

      def handle
        unless Character.find_one_by_name(name1)
          if (self.spell && KeysMagic.is_spell?(self.spell.split(/[+-]/).first))
            client.emit_failure t('keysmagic.npcs_do_not_know_spells')
            return
          else
            self.spell = self.name1
            self.name1 = enactor_name
          end
        end

        spell = KeysMagic.is_spell?(self.spell.split(/[+-]/).first)

        unless spell
          client.emit_failure t('keysmagic.no_such_spell')
          return
        end

        unless KeysMagic.has_spell?(self.name1,spell)
          if self.name1 == enactor_name
            client.emit_failure t('keysmagic.you_do_not_know_spell', :spell => spell)
          else
            client.emit_failure t('keysmagic.they_do_not_know_spell', :spell => spell, :name => self.name1)
          end
          return
        end

        spellinfo = KeysMagic.spells[spell]
        if spellinfo["noroll"]
          client.emit_failure t('keysmagic.spell_does_not_roll', :spell => spell)
          return
        elsif !spellinfo["offense"]
          client.emit_failure t('keysmagic.spell_can_only_roll_unopposed', :spell => spell)
          return
        end

        result = ClassTargetFinder.find(self.name1, Character, enactor)
        model1 = result.target

        if (self.name2)
          result = ClassTargetFinder.find(self.name2, Character, enactor)
          model2 = result.target
          self.name2 = !model2 ? self.name2 : model2.name
          unless self.resist && self.resist.is_integer?
            self.resist = model2 ? self.spell : self.resist
            self.resist = self.name2.is_integer? ? self.name2 : self.resist
          end
        end

        if (!model2 && (self.resist.nil? || !self.resist.is_integer?))
          client.emit_failure t('keysmagic.npc_skill_bad_format')
          return
        end

        die_result1 = KeysMagic.parse_and_cast(model1, self.spell, false)
        die_result2 = KeysMagic.parse_and_cast(model2, self.resist, true)

        if (!die_result1 || !die_result2)
          client.emit_failure t('keysmagic.unknown_spell_params')
          return
        end

        successes1 = FS3Skills.get_success_level(die_result1)
        successes2 = FS3Skills.get_success_level(die_result2)

        until successes1 != successes2 do
          die_result1 = KeysMagic.parse_and_cast(model1, self.spell, false)
          die_result2 = KeysMagic.parse_and_cast(model2, self.resist, true)

          if (!die_result1 || !die_result2)
            client.emit_failure t('keysmagic.unknown_spell_params')
            return
          end

          successes1 = FS3Skills.get_success_level(die_result1)
          successes2 = FS3Skills.get_success_level(die_result2)
        end

        results = FS3Skills.opposed_result_title(self.name1, successes1, self.name2, successes2)

        message = t('keysmagic.opposed_cast_result',
           :name1 => model1.name,
           :name2 => !model2 && (!self.name2.is_integer? || self.name2.is_integer? && self.name2 != self.resist) ? t('fs3skills.npc', :name => self.name2) : self.name2,
           :spell => self.spell,
           :preposition => self.preposition,
           :dice1 => FS3Skills.print_dice(die_result1),
           :dice2 => FS3Skills.print_dice(die_result2),
           :result => results,
           :roller => enactor.name
           )

        FS3Skills.emit_results message, client, enactor_room, self.private_roll
      end
    end
  end
end
