module AresMUSH
  module KeysMagic
    class SpellListRequestHandler
      def handle(request)
        categories = KeysMagic.categories.map { |name, data| {
          name: name,
          icon: KeysMagic.icondir + data['icon'],
          desc: data['desc'],
          attribute: data['attribute'],
          spells: KeysMagic.category_spells(name)
        }}
        spells = KeysMagic.spells
        {
          categories: categories,
          spells: spells
        }
      end

    end
  end
end
