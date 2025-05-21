---
title: "Combining secret values in files on Kubernetes"
tags: kubernetes unix
---

There's a few applications which make handling their associated secrets and
configuration particularly tricky to do on Kubernetes, because the main
configuration file also has many secrets in it.  We don't want to end up in a
position where the secrets are, or could easily be, left in a code repository,
but we also don't necessarily want to put all of our configuration into a
secret that makes it hard to track changes to the configuration over time.

If we store our configuration in a `ConfigMap`, and our secrets in a `Secret`,
we can have a file out of the configuration, and the secrets as environment
variables. Unix has a solution to combining the two: [`envsubst`][1].

I hadn't seen anyone handle secrets like that on Kubernetes, so I thought I'd
give it a go. It worked pretty well, but it is a little cursed.

The `ConfigMap` is fairly conventional:

```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: config
  namespace: combined-secrets
  labels:
    app.kubernetes.io/name: config
data:
  config.yaml.template: |
    ---
    plain_value: Hello world!
    secret_value: $TOP_SECRET_VALUE
```

For `secret_value`, we have a placeholder which will be replaced by `envsubst`.
Then we need a [`Secret`, which here is directly with a file][2] as an example:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: secrets
  namespace: combined-secrets
  labels:
    app.kubernetes.io/name: config
type: Opaque
stringData:
  TOP_SECRET_VALUE: I am very secretive.
```

The values are in all caps, because all of the values will be directly mounted
as environment variables later.

Then, our example `Deployment`:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
  namespace: combined-secrets
  labels:
    app.kubernetes.io/name: deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: deployment
  template:
    metadata:
      labels:
        app.kubernetes.io/name: deployment
    spec:
      initContainers:
        - name: build-config
          command: ["/bin/sh"]
          args:
            - "-c"
            - >
              apt-get update -q; apt-get install -yq gettext-base;
              envsubst < /config.yaml.template > /data/config.yaml
          image: debian
          envFrom:
            - secretRef:
                name: secrets
          volumeMounts:
            - name: shared-files
              mountPath: /data
            - name: config-template
              mountPath: /config.yaml.template
              subPath: config.yaml.template

      containers:
        - image: debian
          name: debian
          command:
            - tail
            - "-f"
            - "/dev/null"
          volumeMounts:
            - name: shared-files
              mountPath: /data

      volumes:
        - name: shared-files
          emptyDir: {}
        - name: config-template
          configMap:
            name: config
```

This uses a couple of tricks to pull this off:

1. We use an [`initContainer`][3] to prepare our configuration before starting
   the main container,
2. To store the result, we use [a volume that's shared among the Pod][4] as
   `/data`,
3. The [Debian][5] container image unfortunately doesn't include `envsubst`, so
   we need to install that ourselves,
4. We also need to [run the commands as a shell for the redirection to
   work][6],
5. To truly cement it's cursed nature: we use `>` which doesn't retain
   line breaks for what's actually a one-liner,
6. Finally, for the main container we `tail` `/dev/null` which is just a trick
   to stop the container exiting whilst we use it.

If we connect to the deployment container, we can see the resulting combined
file:

```
$ kubectl -n combined-secrets exec -it deployment-568b66968-z9t77 -- /bin/bash
Defaulted container "debian" out of: debian, build-config (init)
root@deployment-568b66968-z9t77:/# cat /data/config.yaml
---
plain_value: Hello world!
secret_value: I am very secretive.
```

It's unfortunate that we need to install `gettext` for `envsubst` (it's a good
opportunity for a custom image), but this works well.

[1]: https://linux.die.net/man/1/envsubst
[2]: https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-config-file/
[3]: https://kubernetes.io/blog/2025/04/22/multi-container-pods-overview/
[4]: https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
[5]: https://hub.docker.com/_/debian
[6]: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#run-a-command-in-a-shell
