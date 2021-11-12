module AresMUSH
  module TemplateFormatters
    def line_with_text(text, style=nil)
      # This template is defined in the utils plugin so it can be customized.
      template = LineWithTextTemplate.new(text, style)
      template.render
    end

    def header
      "%lh"
    end

    def footer
      "%lf"
    end

    def divider
      "%ld"
    end

    def line(name)
      return Line.show(name)
    end

    def wrap(str, width, indent = 0, pad_char = " ")
      return nil if !str
      parts = str.scan(/\S.{0,#{width-2}}\S(?=\s|$)|\S+/)
      result = ""
      parts.each_with_index do |line,i|
        if i > 0
          result << "\n#{left(pad_char,indent,pad_char)}"
        end
        result << "#{left(line,width,pad_char)}"
      end
      return result
    end

  end
end
