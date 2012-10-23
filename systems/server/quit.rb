module AresMUSH
  module Commands
    class Quit
      def initialize(config_reader, client_monitor)
        @config_reader = config_reader
        @client_monitor = client_monitor
        @client_monitor.register(self)
      end

      def handles
        ["quit"]
      end
      
      def handle(client, cmd)
        client.disconnect
      end
    end
  end
end
