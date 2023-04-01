module AresMUSH
  module KeysMagic
    class SpellRequestHandler
      def handle(request)
        name = KeysMagic.is_spell?(request.args[:name].gsub(/[_-]/," "))
        original = KeysMagic.spells[name]
        currentspell = Marshal.load(Marshal.dump(original))
        currentspell['desc']['full'] = Website.format_markdown_for_html(currentspell['desc']['full'])
        category = KeysMagic.categories.select { | name, data | currentspell['category'].include? name.to_s }
        pic = KeysMagic.pix.sample
        {
          name: name,
          spell: currentspell,
          category: category,
          pic: pic
        }
      end
    end
  end
end
