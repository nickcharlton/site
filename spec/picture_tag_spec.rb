require "spec_helper"
require_relative "../_plugins/picture_tag"

RSpec.describe Jekyll::PictureTag do
  it "renders with a url and description" do
    output = render(
      <<~SNIPPET
      {% picture some_url %}
      Some description
      {% endpicture %}
      SNIPPET
    )

    expect(output).to eq(
      <<~OUTPUT
        <figure>
          <img src="some_url" alt="Some description" max-width="500px" />
          <figcaption>Some description</figcaption>
        </figure>\n
      OUTPUT
    )
  end
end
