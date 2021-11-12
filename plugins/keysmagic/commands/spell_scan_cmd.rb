module AresMUSH

  module KeysMagic
    class SpellScanCmd
      include CommandHandler

      attr_accessor :topic, :type

      def parse_args
        self.topic = "all"
        self.type = "all"
        @killcmd = false
        if cmd.args
          self.topic = cmd.args.titlecase
          is_spell = KeysMagic.is_spell?(self.topic)
          if KeysMagic.is_category?(self.topic)
            self.type = "category"
          elsif is_spell
            self.type = "spell"
            self.topic = is_spell
          else
            @killcmd = true
          end
        end
      end

      def handle
        if @killcmd
          client.emit_failure t('keysmagic.dunno_what_you_want_from_me')
          return
        end
        template = SpellScanTemplate.new(client, self.topic, self.type)
        client.emit template.render
      end

    end
  end
end
