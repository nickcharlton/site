module Jekyll
  class PictureTag < Liquid::Block
    QuotedString = /"[^"]*"|'[^']*'/
    QuotedFragment = /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/o
    TagAttributes = /(\w[\w-]*)\s*\:\s*(#{QuotedFragment})/o

    def initialize(tag_name, input, options)
      super

      @attributes = {}
      input.scan(TagAttributes) do |key, value|
        @attributes[key] = attribute_parse(value)
      end

      unless attributes.key?("url")
        raise SyntaxError, "picture must have a `url:`" 
      end
    end

    def render(context)
      text = super
      url = attributes["url"]
      alt = attributes["alt"]
      alt_tag = "alt=\"#{alt}\"" if alt
      description = text.strip

      <<~OUTPUT
        <figure>
          <img src="{{ #{url} | absolute_url }}" #{alt_tag} max-width="500px" />
          <figcaption>#{description}</figcaption>
        </figure>
      OUTPUT
    end

    private

    attr_reader :attributes

    def attribute_parse(markup)
      markup = markup.strip
      if (markup.start_with?('"') && markup.end_with?('"')) ||
          (markup.start_with?("'") && markup.end_with?("'"))
        return markup[1..-2]
      end

      markup
    end
  end
end

Liquid::Template.register_tag('picture', Jekyll::PictureTag)
