module AresMUSH
  module Custom
    class LuckXPCmd
      include CommandHandler

      def check_enough_luck
        currentluck = enactor.luck.floor
        return nil if currentluck >= 5
        expressluck = currentluck==0 ? "'re out of Luck!" : " only have " + currentluck.to_s + "."
        return "Sorry, you need to have 5 Luck to trade for an XP. You" + expressluck
      end   
      
      def handle
        enactor.spend_luck(5)
        enactor.award_xp(1)
        expressluck = enactor.luck.floor==0 ? 'no' :  enactor.luck.floor.to_s
        client.emit_success "You have converted your Luck! You now have " + expressluck + " Luck and " + enactor.xp.to_s + " XP."
      end
    end
  end
end
