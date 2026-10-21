---
title: "Building a custom Vagrant metadata server"
tags: projects vagrant ruby
---

Vagrant has long had [a hosted service for boxes][5]. [2014's v1.5 release
announcement contains the earliest reference][2] I could find, and not long
after [in early 2015, I'd created a Ruby client in `atlas-ruby`][3] (I don't
recall if it was originally publicly called Atlas at the time, or it was just
the general domain which was being used and I named the gem accordingly). [By
2017 this had fully become HashiCorp Vagrant Cloud][4], and now it's part of
their wider hosted products and called HCP Vagrant.

But I've always wanted something so that I could host the boxes myself.

After spelunking through some very 2010s-era Ruby, I figured out that it's a
lot simpler than I was expecting, although figuring out everything below took
_ages_. We just have to override `box_server_url` in the `Vagrantfile`, like
so:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "nickcharlton/debian13"
  config.vm.box_server_url = "https://vms.example.com"
 end
```

Vagrant will then try and fetch from that server URL instead of the public one.
We can also set the environment variable of `VAGRANT_SERVER_URL`. This was
introduced in [v1.6.4][1].

We can trace how this works by walking through from the `box add` command,
which runs `action/builtin/box_add.rb` (`up` calls the same code eventually,
but good luck working out how), [the "shorthand" URL is then expanded from line
68 onwards][7]. Eventually this calls methods in
`lib/vagrant/shared_helpers.rb` which defines `Vagrant.server_url`, which given
the box specific configuration, either returns `box_server_url`,
`ENV["VAGRANT_SERVER_URL"]` or `DEFAULT_SERVER_URL` (which is
`https://vagrantcloud.com`).

This eventually leads to two expanded URLs (if the server URL is set to
`https://example.org` and we want the `debian/trixie64` box):

* `https://example.org/api/v2/vagrant/debian/trixie64`
* `https://example.org/debian/trixie64`

Vagrant will hit both of these URLs to see if they return metadata (I don't
know why it does the second, it's presumably legacy and doesn't matter to
re-implement the API). We can `curl` the first one to see what it looks like:

```
$ curl https://vagrantcloud.com/api/v2/vagrant/debian/trixie64 | jq
{
  "name": "debian/trixie64",
  "description": "Debian 13 \"trixie\"",
  "short_description": "",
  "versions": [
    {
      "version": "13.20260121.1",
      "status": "active",
      "description_html": "",
      "description_markdown": "",
      "providers": [
        {
          "name": "libvirt",
          "architecture": "amd64",
          "default_architecture": true,
          "checksum": "ce31963b5ebd206a9a7f1a65e82647d581b1f1345f33bde233b01fb338b05781",
          "checksum_type": "sha256",
          "url": "https://vagrantcloud.com/debian/boxes/trixie64/versions/13.20260121.1/providers/libvirt/amd64/vagrant.box"
        }
      ]
    }
  ]
}
```

So long as we set the correct data type (`application/json`) on the response,
we can substitute our own server by copying the structure:

```ruby
require "sinatra"

get "/api/v2/vagrant/:user/:box" do
  content_type "application/json"

  {
    name: "debian/trixie64",
    description: "Debian 13 \"trixie\"",
    short_description: "",
    versions: [
      {
        version: "13.20260121.1",
        status: "active",
        description_html: "",
        description_markdown: "",
        providers: [
          {
            name: "libvirt",
            architecture: "amd64",
            default_architecture: true,
            checksum: "ce31963b5ebd206a9a7f1a65e82647d581b1f1345f33bde233b01fb338b05781",
            checksum_type: "sha256",
            url: "https://vagrantcloud.com/debian/boxes/trixie64/versions/13.20260121.1/providers/libvirt/amd64/vagrant.box"
          }
        ]
      }
    ]
  }.to_json
end
```

As we only care about fetching boxes here, which is a little confusing to
understand, that's it for now but [the rest of the API is documented well
enough to understand directly][6].

I had some ideas about expanding this into something bigger and more featured
for hosting boxes on your own infrastructure, but for now, I've [published
Vagrant Metadata Server][8], a tiny Sinatra app with a CLI which demonstrates
how this works and is just good enough to pull off hosting your own.

[1]: https://github.com/hashicorp/vagrant/blob/0b7d460a450e0365d2975dbb0d0f0afda5104bca/CHANGELOG.md?plain=1#L2287
[2]: https://www.hashicorp.com/en/blog/vagrant-1-5-and-vagrant-cloud
[3]: https://github.com/nickcharlton/atlas-ruby
[4]: https://www.hashicorp.com/en/blog/vagrant-cloud-migration-announcement
[5]: https://portal.cloud.hashicorp.com/vagrant/discover
[6]: https://developer.hashicorp.com/vagrant/vagrant-cloud/api/v2
[7]: https://github.com/hashicorp/vagrant/blob/f9e2630d69a5e357963bba67dd2be8604ef2b82b/lib/vagrant/action/builtin/box_add.rb#L68-L164
[8]: https://github.com/nickcharlton/vagrant-metadata-server
