module AresMUSH

  module KeysMagic
    class SpellsAllCmd
      include CommandHandler

      def handle
        template = SpellsAllTemplate.new(client)
        client.emit template.render
      end

    end
  end
end
