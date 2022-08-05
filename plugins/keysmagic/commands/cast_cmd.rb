module AresMUSH

  module KeysMagic
    class CastCmd
      include CommandHandler

      attr_accessor :name, :spell, :private_roll

      def parse_args
        if (cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_slash_arg2)
          self.name = titlecase_arg(args.arg1).strip
          self.spell = titlecase_arg(args.arg2).strip
        else
          self.name = enactor_name
          self.spell = titlecase_arg(cmd.args).strip
        end
        self.private_roll = cmd.switch_is?("private")
      end

      def required_args
        [ self.name, self.spell ]
      end

      def handle
        char = Character.named(self.name)
        spell = KeysMagic.is_spell?(self.spell.split(/[+-]/).first.strip)
        modifier_base = "#{self.spell.split(/([+-])/)[1]}"+"#{self.spell.split(/([+-])/)[2]}".delete(" ")
        modifier = modifier_base.nil? ? 0 : modifier_base.to_i

        if !spell
          client.emit_failure t('keysmagic.no_such_spell')
          return
        end

        unless KeysMagic.has_spell?(self.name,spell)
          if self.name == enactor_name
            client.emit_failure t('keysmagic.you_do_not_know_spell', :spell => spell)
          else
            client.emit_failure t('keysmagic.they_do_not_know_spell', :spell => spell, :name => self.name)
          end
          return
        end

        spellinfo = KeysMagic.spells[spell]
        if spellinfo["noroll"]
          client.emit_failure t('keysmagic.spell_does_not_roll', :spell => spell)
          return
        elsif spellinfo["offense"] && spellinfo["offense"]["only"]
          client.emit_failure t('keysmagic.spell_cannot_roll_unopposed', :spell => spell)
          return
        end

        if spell == "Key Maker"
            Global.logger.info "#{modifier_base}"
            Global.logger.info "#{self.spell}"
            time_roll = FS3Skills::RollParams.new("Law", modifier, "Wits")
            place_roll = FS3Skills::RollParams.new("Chaos", modifier, "Grit")
            time_result = FS3Skills.roll_ability(char, time_roll)
            place_result = FS3Skills.roll_ability(char, place_roll)
            time_level = FS3Skills.get_success_level(time_result)
            time_title = FS3Skills.get_success_title(time_level)
            place_level = FS3Skills.get_success_level(place_result)
            place_title = FS3Skills.get_success_title(place_level)
            message = t('keysmagic.keymaker_cast_result',
              :name => char ? char.name : "#{self.name}",
              :spell => "#{self.spell}",
              :time_dice => FS3Skills.print_dice(time_result),
              :place_dice => FS3Skills.print_dice(place_result),
              :time_success => time_title,
              :place_success => place_title,
              :roller => enactor.name
            )
            FS3Skills.emit_results message, client, enactor_room, self.private_roll
          return
        end

        if (char)
          die_result = KeysMagic.parse_and_cast(char, self.spell, false)
        else
          die_result = nil
        end

        if !die_result
          client.emit_failure t('keysmagic.unknown_spell_params')
          return
        end

        success_level = FS3Skills.get_success_level(die_result)
        success_title = FS3Skills.get_success_title(success_level)
        message = t('keysmagic.simple_cast_result',
#          :name => char ? char.name : "#{self.name} (#{enactor_name})",
         :name => char ? char.name : "#{self.name}",
         :spell => self.spell,
          :dice => FS3Skills.print_dice(die_result),
          :success => success_title,
          :roller => enactor.name
        )
        FS3Skills.emit_results message, client, enactor_room, self.private_roll
      end

    end
  end
end
