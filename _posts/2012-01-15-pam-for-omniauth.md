---
title: "PAM for OmniAuth: omniauth-pam"
tags: ruby, pam, linux, authentication, omniauth
---

I have a couple of small web applications that I have built for myself (wiki, system monitoring, etc.) There didn't seem much point in adding a database for authentication, so I put together a strategy for using [PAM](http://en.wikipedia.org/wiki/Linux_PAM) and [OmniAuth](https://github.com/intridea/omniauth/).

It depends on OmniAuth (~> 1.0), [`rpam-ruby19`](https://github.com/canweriotnow/rpam-ruby19) and the PAM headers (that's the `libpam0g-dev` package on [Debian](http://packages.debian.org/squeeze/libpam0g-dev) and Ubuntu.)

It has only been tested on Debian 6.0 using Ruby 1.9.3-p0 (but there's no reason why it won't work elsewhere.)

[The project is on GitHub](http://github.com/nickcharlton/omniauth-pam). Log an issue if something doesn't work as you expect.

### Usage

Include provider type: 

	use Rack::Session::Cookie
	use OmniAuth::Strategies::PAM

Implement the callback (as in the OmniAuth documentation), and then navigate to: `/auth/pam`.

It uses the authenticated user as the UID, as on a Linux system this would be unique.

### Supporting Ruby 1.8

There is an older gem available for Ruby 1.8 for supporting PAM. The syntax is slightly different, but only a small change if you wanted it.

Instead of including `rpam-ruby19` instead use [`rpam`](http://rpam.rubyforge.org/) and change the implementation of `callback_response` in `lib/omniauth/strategies/pam.rb` to:

    def callback_phase
        unless authpam(request['username'], request['password'])
            return fail!(:invalid_credentials)
        end

        super
    end

You will also need to add `include Rpam` beneath `include OmniAuth::Strategy`.

As it's only small (the whole thing is tiny as it is) I figured it'd be best to document the difference, rather than aim to support two different gems.

