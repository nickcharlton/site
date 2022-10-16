---
title: Using Postmark with Sinatra
tags: ruby sinatra mail postmark
---

I usually use [Postmark][] for outgoing transactional email, I find this to be
better than expecting the underlying system to have a correctly configured
`sendmail` and it helps with deliverability. [Sinatra][], though, doesn't have a
convention for handling email. The [Sinatra FAQ][] lists an example using
[Pony][], so going from there, here's an example of using the [Postmark Gem][]
with Sinatra:

```ruby
require 'sinatra'
require 'postmark'

configure do
  set :mailer, Postmark::ApiClient.new('')
end

get '/send_mail' do
  settings.mailer.deliver(from: 'example@example.com',
                          to: 'example@example.com',
                          subject: 'A Test Email',
                          text_body: 'A simple plain text test email.')
end
```

I'm just using the standard settings handling to keep hold of the Postmark
client here. You could do it in any way. You can also render views (like you'd
typically do with ActionMailer), like so:

```ruby
get '/send_html_mail' do
  settings.mailer.deliver(from: 'example@example.com',
                          to: 'example@example.com',
                          subject: 'An HTML Test Email',
                          html_body: erb(:email))
end
```

…where, `:email` is `email.erb` in `views/`:

```html
<p>A simple <i>HTML</i> test email.</p>
```

And then you have simple Postmark email support. The rest of the [Postmark Gem][]
documentation details everything else you'd be able to do with it.

[Postmark]: https://postmarkapp.com
[Sinatra]: http://www.sinatrarb.com
[Sinatra FAQ]: http://www.sinatrarb.com/faq.html#email
[Pony]: https://github.com/benprew/pony
[Postmark Gem]: https://github.com/wildbit/postmark-gem
