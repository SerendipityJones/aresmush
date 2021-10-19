module AresMUSH
  class Character
    attribute :unified_play_screen, :type => DataType::Boolean
    attribute :channel_handles, :type => DataType::Boolean

    def alts
      # Note - includes the original character
      AresCentral.alts(self)
    end
  end

  class Handle
    attribute :profile
  end
end
