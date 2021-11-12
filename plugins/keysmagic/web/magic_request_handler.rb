module AresMUSH
  module KeysMagic
    class MagicRequestHandler
      def handle(request)
        text = Global.read_config("keysmagic", "magic page")
        text['before']=Website.format_markdown_for_html(text['before'])
        text['after']=Website.format_markdown_for_html(text['after'])
        {
          text: text
        }
      end
    end
  end
end
