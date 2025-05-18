---
title: "Static files with Nginx, Docker & Kubernetes"
tags: nginx docker kubernetes
---

I wanted a way to serve up a set of `.well-known` paths, as easily as I could
get away with, but keep it all alongside some other Kubernetes manifests.

I hoped it'd be something I could trick the [Nginx Ingress controller][3] into
doing (as that already exists), perhaps with just a `ConfigMap` but it's not
really designed to do that. I didn't think it should be necessary to build a
custom container image either. But we could do it with a `Deployment` and an
Nginx container. There's a bit to it, but perhaps it's helpful for others.

I'm going to use [Matrix's `.well-known` paths][1] here, but the same principle
could apply to anything static.

## A quick experiment with Docker

To start with, we need something to serve:

```json
# .well-known/matrix/server
{
  "m.server": "matrix.nickcharlton.net:443"
}
```

We can then serve it by mounting the current directory in the right place,
using the [Nginx Docker image][2]:

```sh
docker run --rm -p 8080:80 -v .:/usr/share/nginx/html:ro nginx
```

And test it with `curl`:

```sh
$ curl http://localhost:8080/.well-known/matrix/server
{
  "m.server": "matrix.nickcharlton.net:443"
}
```

That works quite nicely, which is just enough experimenting to turn it into
Kubernetes manifests.

## Running on Kubernetes

To start with, a `ConfigMap` to hold the data:

```yaml
# configmap-well-known.yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: well-known
  namespace: default
  labels:
    app.kubernetes.io/name: well-known
data:
  server: |
    {
      "m.server": "matrix.nickcharlton.net:443"
    }
```

Then a `Deployment` to run Nginx:

```yaml
# deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: well-known
  namespace: default
  labels:
    app.kubernetes.io/name: well-known
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: well-known
  template:
    metadata:
      labels:
        app.kubernetes.io/name: well-known
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          volumeMounts:
            - name: data
              mountPath: /usr/share/nginx/html/.well-known/matrix/server
              subPath: server
      volumes:
        - name: data
          configMap:
            name: well-known
```

Finally, a Service and Ingress:

```yaml
# service.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: well-known
  namespace: default
  labels:
    app.kubernetes.io/name: well-known
spec:
  # type: LoadBalancer
  clusterIP: None
  ports:
    - name: http
      port: 80
      targetPort: http
  selector:
    app.kubernetes.io/name: well-known
```

```yaml
# ingress.yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: well-known
spec:
  ingressClassName: nginx
  rules:
    - host: nickcharlton.net
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: well-known
                port:
                  name: http
```

I use [kube-vip][4] on my clusters, so I could use a `LoadBalancer`
service here to get an IP outside of the cluster and use that (a pattern you
can use elsewhere too). But, it's also possible to use a headless service with
an Ingress, which is what's done here.

We can test via the Ingress directly by forwarding a port:

```sh
$ kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

```sh
$ curl --resolve nickcharlton.net:8080:127.0.0.1 http://nickcharlton.net:8080/.well-known/matrix/server
{
  "m.server": "matrix.nickcharlton.net:443"
}
```

Or, if we can access outside the cluster (assuming the domain resolves):

```sh
$ curl http://nickcharlton.net:8080/.well-known/matrix/server
{
  "m.server": "matrix.nickcharlton.net:443"
}
```

[1]: https://spec.matrix.org/v1.14/client-server-api/#well-known-uri
[2]: https://hub.docker.com/_/nginx
[3]: https://kubernetes.github.io/ingress-nginx/
[4]: https://kube-vip.io/
