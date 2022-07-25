module AresMUSH
  module Yky
    class YkyRequestHandler

      def handle(request)

        enactor = request.enactor

        error = Website.check_login(request, true)
        return error if error

        yky = Global.read_config("wikipix", "called")

        {
          yky: "#{yky.sample}"
        }

      end
    end
  end
end
