module AresMUSH
  module KeysMagic
    class SpellRequestHandler
      def handle(request)
        name = KeysMagic.is_spell?(request.args[:name].gsub(/[_-]/," "))
        spell = KeysMagic.spells[name]
        spell['desc']['full'] = Website.format_markdown_for_html(spell['desc']['full'])
        category = KeysMagic.categories.select { | name, data | spell['category'].include? name.to_s }
        pic = KeysMagic.pix.sample
        {
          name: name,
          spell: spell,
          category: category,
          pic: pic
        }
      end
    end
  end
end
