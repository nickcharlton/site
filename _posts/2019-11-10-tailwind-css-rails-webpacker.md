---
title: "Tailwind CSS with Rails 6 and Webpacker"
published: 2019-11-10 15-59-50 +00:00
tags: tailwind rails webpacker css
---

I don't do many things frontend these days, but I've wanted to try out
[Tailwind][] for a while, and I finally had the opportunity. Alas, it was a
Rails app which had no frontend at all (apart from [administrate][]), so I
need to start from the very beginning. Here's how I did it:

[Tailwind]: https://tailwindcss.com
[administrate]: https://github.com/thoughtbot/administrate

## Webpacker

I needed to add [Webpacker][], as I'd initially not done this when generating
the application. You should be able to skip this if you already have a working
setup. First, I added `webpacker` to the `Gemfile` and then ran the generator:

```sh
bundle exec rails webpacker:install
```

This command configures much of what's needed. The `Webpacker` directory
layout ends up looking like this:

```
app/javascript
├── packs
│   └── application.js
└── src
```

`packs` contain the collection of functionality processed with Webpacker to
build the package of JavaScript (and CSS!) that serves your application. The
default one being `application.js`.

In `app/javascript/packs/application.js`, I have the following:

```js
require("@rails/ujs").start()
require("turbolinks").start()
```

And then, in the application layout, we'll add the two hooks required to get
JavaScript and styles included:

```erb
<%= stylesheet_pack_tag "application", media: "all", "data-turbolinks-track": "reload" %>
<%= javascript_pack_tag "application", "data-turbolinks-track": "reload" %>
```

Which loads both the JavaScript `application` pack and the separated stylesheet.
These replace any existing `stylesheet_link_tag`/`javascript_link_tag` usage.

[Webpacker]: https://github.com/rails/webpacker

## Tailwind CSS

Then, I added `tailwindcss` to the `package.json` using Yarn:

```sh
yarn add tailwindcss --dev
```

And generated a Tailwind CSS config file:

```sh
npx tailwindcss init app/javascript/src/tailwind.config.js
```

The configuration file starts empty and looks like this:

```js
module.exports = {
  theme: {},
  variants: {},
  plugins: [],
}
```

To setup Tailwind, I'm importing the suggested imports in
`app/javascript/css/application.css`:

```css
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";
```

Webpacker is using `postcss-import`, so here I'm not using `@tailwind` to pull
in the dependency [as suggested in the documentation][docs].

[docs]: https://tailwindcss.com/docs/installation/#2-add-tailwind-to-your-css

To configure PostCSS, I needed to add Tailwind in the right place (and
overwrite the default location it loads the config file from):

```js
module.exports = {
  plugins: [
    require('autoprefixer'),
    require('postcss-import'),
    require('tailwindcss')('./app/javascript/src/tailwind.config.js'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009',
      },
      stage: 3,
    }),
  ],
};
```

Finally, I needed to configure Webpacker to expose a standalone CSS file for
every environment in the `default` section of `config/webpacker.yml`:

```yaml
# Extract and emit a css file
extract_css: true
```

(You can also to delete the same line overridden in `production`.)

Asset management in Rails is gradually moving towards Webpacker, and this is
probably a good thing &mdash; standardising around the most common tools used
in the JavaScript community. But it's still a bit confusing if this isn't
something do you often.
