module AresMUSH
  module Demographics
    class BirthdayCensusRequestHandler
      def handle(request)
        chars = Chargen.approved_chars.select(&:birthdate).sort_by(&:birthday)

        census = []

        chars.each do |c|
          char_data = {}
          char_data['char'] = {
            name: c.name,
            icon: Website.icon_for_char(c),
          }
          char_data['age'] = c.age
          char_data['month'] = c.birthdate.strftime("%B")
          char_data['day'] = c.birthdate.strftime("%-d")

          census << char_data
        end

        {
          titles: ['Name', 'Age', 'Month', 'Day'],
          chars: census
        }
      end
    end
  end
end
