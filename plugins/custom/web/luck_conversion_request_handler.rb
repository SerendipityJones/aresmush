module AresMUSH
  module Custom
    class LuckConversionRequestHandler
      def handle(request)
        enactor = request.enactor
        char = Character.find_one_by_name(request.args[:id])

        error = Website.check_login(request)
        return error if error

        if (!char)
          return { error: t('webportal.not_found') }
        end

        currentluck = char.luck.floor
        return { error: "Sorry, you need to have 5 Luck to trade for an XP." } if currentluck < 5
        char.spend_luck(5)
        char.award_xp(1)
        expressluck = char.luck.floor==0 ? 'no' :  char.luck.floor.to_s
        success = "You have converted your Luck! You now have " + expressluck + " Luck and " + char.xp.to_s + " XP."

        return { success: success }

      end

    end
  end
end
