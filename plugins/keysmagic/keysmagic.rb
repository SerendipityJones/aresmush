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
        when "note"
          return SpellNoteCmd
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
      when "spellcount"
        return SpellcountCmd
      when "cast"
        if ((cmd.args =~ / vs /) || (cmd.args =~ / on /))
          return OpposedCastCmd
        else
          return CastCmd
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
      when "charSpellList"
        return CharSpellListRequestHandler
      when "charSpellLearn"
        return CharSpellLearnRequestHandler
      when "charSpellLearnable"
        return CharSpellLearnableRequestHandler
      when "charSetSpellNote"
        return CharSpellNoteRequestHandler  
      when "addSceneSpell"
        return AddSceneSpellRequestHandler
      end
      nil
    end

  end
end
