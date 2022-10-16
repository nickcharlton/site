require "spec_helper"
require_relative "../_plugins/picture_tag"

RSpec.describe Jekyll::PictureTag do
  it "raises unless url is provided" do
    silence do
      expect do
        render(
          <<~SNIPPET
        {% picture %}
        Some description
        {% endpicture %}
          SNIPPET
        )
      end.to raise_error(SyntaxError)
    end
  end

  it "renders with a url and description" do
    output = render(
      <<~SNIPPET
      {% picture url: some_url %}
      Some description
      {% endpicture %}
      SNIPPET
    )

    expect(output).to eq(
      <<~OUTPUT
        <figure>
          <img src="{{ some_url | absolute_url }}" max-width="500px" />
          <figcaption>Some description</figcaption>
        </figure>\n
      OUTPUT
    )
  end

  it "renders with a url, description and alt text" do
    output = render(
      <<~SNIPPET
      {% picture url: some_url, alt: "Some alt text" %}
      Some description
      {% endpicture %}
      SNIPPET
    )

    expect(output).to eq(
      <<~OUTPUT
        <figure>
          <img src="{{ some_url | absolute_url }}" alt="Some alt text" max-width="500px" />
          <figcaption>Some description</figcaption>
        </figure>\n
      OUTPUT
    )
  end
end
