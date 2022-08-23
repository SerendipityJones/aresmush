$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Custom
    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("custom", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
        when "check"
          case cmd.switch
          when "pools"
            return CheckPoolsCmd
          when "luck"
            return CheckLuckCmd
          when "xp"
            return CheckXPCmd
          when nil
            return CheckPoolsCmd
          end
        when "luck"
          case cmd.switch
          when "xp"
            return LuckXPCmd
          end
        when "dotcount"
          return DotcountCmd
        when "wordcount"
          case cmd.switch
          when "alts"
            return WordCountAltsCmd
          when nil
            return WordCountCmd
          end
        end  
      return nil
    end
  end
end
