module AresMUSH

  module KeysMagic
    class SpellInfoCmd
      include CommandHandler

      attr_accessor :spell

      def parse_args
        @killcmd = false
        if cmd.args
          self.spell = cmd.args.titlecase
          is_spell = KeysMagic.is_spell?(self.spell)
          if is_spell
            self.spell = is_spell
          else
            @killcmd = true
          end
        else
          @killcmd = true
        end
      end

      def handle
        if @killcmd
          client.emit_failure t('keysmagic.no_such_spell')
          return
        end
        template = SpellInfoTemplate.new(self.spell)
        client.emit template.render
      end

    end
  end
end
