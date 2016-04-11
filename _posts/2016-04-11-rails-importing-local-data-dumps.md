---
title: "Rails: Importing Local Data Dumps"
published: 2016-04-11 16:06:00 +0000
tags: rails postgres mysql
---

I regularly work with production data (obfuscated when necessary) with local
[Rails][] apps. It's much better to work with real-world data when building out
projects as it allows you to make decisions according to what will really
happen.

But, importing them can be a bit of a pain. I'd previously been writing out the
command for `pg_import` manually. So, I wrote a quick Rake task to do this for
me:

```ruby
namespace :db do
  desc "Import a given file into the database"
  task :import, [:path] => :environment do |_t, args|
    dump_path = args.path
    connection_config = ActiveRecord::Base.connection_config

    case connection_config[:adapter]
    when "postgresql"
      system("PGPASSWORD=#{connection_config[:password]} pg_restore " \
        "--verbose --clean --no-acl --no-owner " \
        "--username=#{connection_config[:username]} " \
        "-d #{connection_config[:database]} #{dump_path}")
    when "mysql", "mysql2"
      system("mysql -u #{connection_config[:username]} " \
        "-p#{connection_config[:password]} " \
        "#{connection_config[:database]} < #{dump_path}")
    else
      raise NotImplementedError, "An importer hasn't been implemented for: " \
        "#{connection_config[:adapter]}"
    end
  end
end
```

This uses the database configuration for the current Rails environment to
invoke the standard tools for importing into [Postgres][] and [MySQL][]. If a
different database adaptor is being used, it'll safely fail with a message.

Postgres doesn't provide a command line manner in which to provide the
password, so we're using the ([not-recommended][]) approach of using an
environment variable. In our case, this shouldn't be an issue as this is
intending to be imported into a local development database.

Rake's argument handling can appear a little strange (because you can run
multiple commands at once, using `OptParser` becomes a little bit more
complex), but it's executed like so:

```sh
bundle exec rake db:import[latest.dump]
```

…where `latest.dump` is a file in the same directory as you're executing the
command.

This version supports just Postgres and MySQL as I don't come across others so
regularly, more database adaptors are left as an exercise for the reader.

[Rails]: http://rubyonrails.org
[Postgres]: http://www.postgresql.org/docs/current/static/app-pgrestore.html
[MySQL]: https://dev.mysql.com/doc/refman/5.7/en/mysql-batch-commands.html
[not-recommended]: http://www.postgresql.org/docs/current/static/libpq-envars.html
