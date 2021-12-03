module Jekyll
  class PictureTag < Liquid::Block
    def initialize(tag_name, input, options)
      super

      @input = input
    end

    def render(context)
      text = super
      url = input.strip
      description = text.strip

      <<~OUTPUT
        <figure>
          <img src="#{url}" alt="#{description}" max-width="500px" />
          <figcaption>#{description}</figcaption>
        </figure>
      OUTPUT
    end

    private

    attr_reader :input
  end
end

Liquid::Template.register_tag('picture', Jekyll::PictureTag)
