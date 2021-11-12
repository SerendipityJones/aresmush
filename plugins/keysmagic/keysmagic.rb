$:.unshift File.dirname(__FILE__)

module AresMUSH
  module KeysMagic

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("keysmagic", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "spell"
        case cmd.switch
        when "add"
          return AddSpellCmd
        when "remove"
          return RemoveSpellCmd
        when "scan"
          return SpellScanCmd
        else
          return SpellInfoCmd
        end
      when "spells"
        case cmd.switch
        when "all"
          return SpellsAllCmd
        else
          return SpellsKnownCmd
        end
      end
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when "magic"
        return MagicRequestHandler
      when "spell"
        return SpellRequestHandler
      when "spells"
        return SpellListRequestHandler
      when "charSpells"
        return CharSpellsRequestHandler
      end
      nil
    end

  end
end
