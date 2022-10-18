---
title: "Kubernetes with Terraform on Google Cloud"
tags: terraform kubernetes google-cloud
---

I've been playing around with [Kubernetes][] a bunch recently, especially with
[Google Kubernetes Engine][] (GKE). [Google Cloud][], and especially, their
managed Kubernetes solution works really well. The best tool for configuring
this sort of thing is [Terraform][], but the few examples I came across had
lots of extra complexity which I felt distracted from what really needed to be
there. This starts with a very basic implementation to bring up a cluster,
through to some useful configuration for nodes which you can build on.

## Setup

Firstly, if you haven't already, make sure you have an account with [Google
Cloud][], have installed Terraform and the [Google Cloud SDK][]. Then, there
are some configuration prerequisites to walk through.

Google Cloud organises resources under a "project". Here, I'm going to be using
`terraform-gke` as an example project to work with. You can set this up in the
[Google Cloud Console][].

Next, we need to set up a few things to have access via the API. First,
[enable the GKE API in the Google Developer's Console][gke-api]. Then, we'll
need service account credentials to use the API. In the "Credentials" section,
choose "Create Credentials" and then "Service account key".

You should then be asked to select which account to use. If GKE API access is
setup correctly, you'll see "Compute Engine default service account". That'll
do fine for our requirements, so select that and "JSON" as the type.

Now, create a file for the provider, e.g.: `google.tf`:

```
provider "google" {
  credentials = "${file("account.json")}"
  project     = "terraform-gke"
  region      = "europe-west2"
}
```

The `account.json` file is what we'd previously downloaded. Setting the project
here allows us to avoid setting it elsewhere, and the same with the [region][].

Finally, `terraform init` to have Terraform download the required provider.

## Basic Cluster

```
resource "google_container_cluster" "primary" {
  name               = "gke-example"
  zone               = "europe-west2-a"
  initial_node_count = 2
}
```

This is the most basic, but workable cluster I could come up with. It has two
nodes, exists in a single availability zone and uses the smallest standard
[machine type][] available (which defaults to `n1-standard-1`). It's named
`gke-example`. You could place this in the same `google.tf` file, but any `.tf`
would do.

If you run `terraform apply`, this will bring the cluster up.

To use `kubectl`, the credentials can be fetched using `gcloud`:

```sh
gcloud config set project terraform-gke
gcloud container clusters get-credentials gke-example
```

…which sets the correct project, and then fetches the credentials for our
cluster. Now, `kubectl cluster-info` should tell you something about the
cluster which was just created.

## Managing the Default Node Pool

GKE uses the idea of "node pools" to segregate specific types of nodes in a
cluster. You might have a set of default size nodes which are applicable to
most job requirements, but some high-memory nodes for larger batch jobs or
perhaps some with attached GPUs for some machine learning work.

By default, creating a cluster (either through Terraform, or manually with the
`gcloud` client will create a default node pool which you're not able to manage
yourself. This means that if you want to enable auto-scaling, custom machine
types or any of the management options, this isn't available to you through
Terraform.

The solution to this is to delete the initial node pool and provide our own.

We can do this like so:

```
resource "google_container_cluster" "primary" {
  name                     = "gke-example"
  zone                     = "europe-west2-a"
  remove_default_node_pool = true

  node_pool {
    name = "default-pool"
  }
}

resource "google_container_node_pool" "primary_pool" {
  name       = "primary-pool"
  cluster    = "${google_container_cluster.primary.name}"
  zone       = "europe-west2-a"
  node_count = "2"

  node_config {
    machine_type = "n1-standard-1"
  }
}
```

We need to either provide an `initial_node_count` or a `node_pool` block, so
here we just name the default node pool. This is the node which will be removed
after initial cluster creation. We then go onto configuring the "primary pool"
with two `n1-standard-1` nodes.

## Improving the Initial Nodes

One of the great things about running on a managed Kubernetes provider is
having the sort of the upgrade and repair functionality you'd only get with a
legion of staff in a traditional hosting environment.

For [auto-upgrades][], this helps ensure you're running a recent stable build
of Kubernetes across your cluster and for [auto-repair][], it ensures that
every node in the cluster is functioning correctly. If a node is behaving
incorrectly, the provisioned Pods will be migrated off and the node replaced
with a new one.

These two features can be enabled with the `management` block inside the
node pool:

```
management {
  auto_repair  = true
  auto_upgrade = true
}
```

GKE also supports another great feature: Auto-scaling. If the required load on
the cluster can't be handled by the amount of currently provisioned nodes,
GKE will spin up more nodes (up to a limit). In the reverse, if there's ample
capacity on the cluster, GKE will remove nodes from it.

Much like the management functionality, this can be enabled inside the node
pool block:

```
autoscaling {
  min_node_count = 2
  max_node_count = 5
}
```

Whilst this is something that'll depend much on your use case, it seems wise to
keep the auto-scaling max just above the peak load you'd expect to see in
normal circumstances. But, of course, your mileage will vary.

## Additional Node Pools & Preemptable Nodes

Not all of your workloads might warrant the same set of underlying nodes. If
you have a few background jobs which require much more memory but otherwise
have a workload which is primarily web requests, you might save money by adding
an additional node pool for the background jobs that are configured with a
different machine type.

Some of your workloads might be fault-tolerant enough to use [Preemptable
VMs][], which are priced significantly cheaper than normal instances but only
exist for 24hrs (before being re-provisioned) and might be terminated on
short notice.

You can use [node taints inside Kubernetes][node-taint] to make sure the right
jobs right on the right nodes. In Terraform, these are configured just like our
`primary-pool` above.

[Kubernetes]: https://kubernetes.io
[Google Kubernetes Engine]: https://cloud.google.com/kubernetes-engine/
[Google Cloud]: https://cloud.google.com
[Terraform]: https://terraform.io
[Google Cloud SDK]: https://cloud.google.com/sdk/docs/
[Google Cloud Console]: https://console.cloud.google.com/
[gke-api]: https://console.developers.google.com/apis/api/container.googleapis.com/overview
[region]: https://cloud.google.com/appengine/docs/locations
[machine type]: https://cloud.google.com/compute/docs/machine-types
[auto-upgrades]: https://cloud.google.com/kubernetes-engine/docs/concepts/node-auto-upgrades
[auto-repear]: https://cloud.google.com/kubernetes-engine/docs/concepts/node-auto-repair
[Preemptable VMs]: https://cloud.google.com/kubernetes-engine/docs/concepts/preemptible-vm
[node-taint]: https://cloud.google.com/kubernetes-engine/docs/how-to/node-taints
