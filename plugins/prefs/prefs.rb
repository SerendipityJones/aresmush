$:.unshift File.dirname(__FILE__)

module AresMUSH
     module Prefs

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("prefs", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "prefs"
        case cmd.switch
        when "list"
          return ListPrefsCmd
        when "notes"
          return PrefsNotesCmd
        when nil
          return PrefsCmd
        end
      when "pref"
        case cmd.switch
        when "set"
          return SetPrefCmd
#        when "note"
#          return PrefNoteCmd
        when nil
          return PrefCmd  
        end  
      end
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when "prefs"
        return PrefsRequestHandler
      end
      nil
    end

  end
end
