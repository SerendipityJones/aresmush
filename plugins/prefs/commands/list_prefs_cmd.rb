module AresMUSH
  module Prefs
    class ListPrefsCmd
      include CommandHandler

      def handle 
        pref_list = Prefs.preferences
        template = PrefsListTemplate.new(pref_list)
        client.emit template.render
      end

    end
  end
end      