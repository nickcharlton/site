---
title: "Prometheus Remote Write Examples"
tags: prometheus metrics
---

Last year, I worked on a project that sends telemetry data to [Grafana
Cloud][1]. It was data from remote sensors (i.e.: internet of things) and my
theory was that having the data end up in Prometheus would be ideal for data
storage, software licensing and general support reasons as then it'd be
possible to query the sensor data like any other application metrics.

In practice this worked out pretty well, and I'm really happy with how it
worked out. _But_, with how [`prometheus_exporter`][2] ends up exposing the
metrics, you end up with a situation where the metric data persists. Instead of
the data being a point in time, the value stays constant between scrapes.
Whilst this is inherent to the design, it means that unless the whole
application is restarted (or goes down), you lose any gaps in the data which is
itself a helpful piece of information that you can alert on. For a specific
example: if temperature data is sent every 5 minutes at 21ºC, unless that value
changes, the scraped data will always report 21ºC from that point onwards.

This can be solved by _pushing_ rather than _pulling_ metrics, but is something
that Prometheus tries to steer you away from doing. There is a solution to this
in the [push gateway][3], but in this situation I couldn't use it (without
increasing the infrastructure complexity). Prometheus also supports [remote
write][4]; intended for other scrapers to send data to another Prometheus.

There's a specification for remote write is supposed to work, but if you look
through the various client libraries, this isn't implemented (usually
deliberately to stop you using it) and I couldn't find any helpful examples of
how to use it. Whilst I never got time to implement it on the project it was
intended for, I did end up writing some examples of implementing Remote Write,
and [I've collected these together in a repository in case it's useful for
others][5].

[1]: https://grafana.com/products/cloud/
[2]: https://github.com/discourse/prometheus_exporter
[3]: https://prometheus.io/docs/instrumenting/pushing/
[4]: https://prometheus.io/docs/specs/prw/remote_write_spec/
[5]: https://github.com/nickcharlton/prometheus-remote-write
