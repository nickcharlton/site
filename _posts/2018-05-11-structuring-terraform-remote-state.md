---
title: "Structuring Terraform with Remote State"
published: 2018-05-11 09-55-07 +01:00
tags: terraform
---

I've been using [Terraform][] for just about four years at this point, but
outside working with other organisations' configuration, I've not sat down and
built something from scratch since the very beginning. Then, I'd only had a
single environment that was configuring DNS for all of my domains or was
putting together examples for [other][terraform-aws-vpc]
[projects][k8s-gcloud].

But most recently, I've wanted to pull this configuration together as I've been
experimenting with [Kubernetes on Google Cloud][k8s-gcloud] and to have
something to point to when recommending to folks just starting to build out
their configurations.

A common problem I'd been seeing is mistakes in one environment breaking others
(nothing like building test cluster and nearly bring down production!) and when
splitting by environment, struggling to share common configuration between
them. When collaborating across teams, all of these problems are exacerbated.

I'd wanted to figure out an approach which would either solve or mitigate these
issues and that would be a foundation to build upon. In coming up with this,
I've taken a lot from [Charity Major's writing][charity-terraform], [The Packer
Book][packer-book] (which filled in many gaps in my understanding when it came
to how remote state could all fit together) and
[Travis CI's open source configuration][travis-terraform]. I recommend
exploring all of these.

## Understanding Remote State

The solution to some of these problems (splitting environments, collaboration,
etc.) lies in using [remote state][]. This wasn't a feature back when I started
using Terraform but opens up some interesting patterns.

Terraform uses the state to [build a map between your configuration files, the
real-world resources which back them, and how the dependencies slot
together][state-purpose]. By default, this is held locally.

This works out okay for small projects, but as your configuration and those
trying to collaborate on grow this begins to become unwieldy. You risk
overwriting someone else's changes or suffering through particularly horrible
merge conflicts.

Remote state helps mitigate these. The [backend][] can provide locking so that
people's changes don't override another's (for example, S3 with a DynamoDB
table or Consul) and data can be referred to across different environments
which brings with it the opportunity for smart separation of concerns when it
comes to Terraform configuration.

## Directory Structure

Something I'd struggled with when reading other things was understanding the
bigger picture of how everything could fit together, and some limitations
imposed by how Terraform works with directories. Before going over the details
of each directory, here's the overall directory structure that I've been
working with:

```
modules/ # shared modules
  remote_state/
    interface.tf
    main.tf
state/ # "environment" for bootstrapping state buckets
  main.tf
  terraform.tfstate
global/ # everything which doesn't fit inside a specific environment
  main.tf
production/
  main.tf
```

This focuses on each of the environments, one of which is for handling the
state (and the only one with a local file `.tfstate`), one for things like DNS
or IAM details which don't fit into a specific environment and then the first
true environment, `production`. `modules` allow us to share between
environments.

Terraform doesn't descend any further than the current directory when looking
for `*.tf` files. This means that it's not possible to use directories for
grouping (e.g.: you can't do `global/dns/main.tf` and `global/iam/main.tf`, for
example). Instead, this encourages us to push configuration into reusable
modules and simplify the depth of the directory tree.

Depending on needs, it might make sense to annotate regions inside the
environment name, such as `europe-production`, `us-production`, etc.

## Workflow

Initially, you'll want to work inside `state` to build up the resources
required for storing state for the rest of your environments. Depending on your
circumstances, you may find this is better implemented independently from the
main Terraform configuration, but I've found it's fine in the same repository.
It might look something like this:

```
# state/main.tf
provider "aws" {
  version = "~> 1.15"
  region  = "eu-west-1"
}

module "remote_state_global" {
  source = "../modules/remote_state"

  environment = "global"
}

module "remote_state_production" {
  source = "../modules/remote_state"

  environment = "production"
}
```

```
# modules/remote_state/interface.tf
variable "prefix" {
  default     = "ng-test"
  description = "Organisation Name to prefix buckets with"
}

variable "environment" {
  default     = "development"
  description = "Environment Name"
}

output "s3_bucket_id" {
  value = "${aws_s3_bucket.remote_state.id}"
}

# modules/remote_state/main.tf
resource "aws_s3_bucket" "remote_state" {
  bucket = "${var.prefix}-remote-state-${var.environment}"
  acl    = "authenticated-read"

  versioning {
    enabled = true
  }

  tags {
    Name        = "${var.prefix}-remote-state-${var.environment}"
    Environment = "${var.environment}"
  }
}
```

After this, you can start building out one of the environments. I found
thinking about the `global` environment the easiest place to start; it holds
many prerequisites for the other environments, like DNS, S3 buckets and IAM
details. It might look something like this:

```
# global/main.tf
terraform {
  backend "s3" {
    bucket = "ng-test-remote-state-global"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 1.15"
  region  = "eu-west-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "ng-test-example"
  acl    = "private"

  tags {
    Name        = "NG: Test Example Bucket"
    Environment = "ng-test"
  }
}
```

As you start developing infrastructure, patterns will start to emerge. This can
be build up into [Terraform Modules][] and shared. A [public registry][] exists
which can help speed up understanding what you can do.

[Terraform]: https://www.terraform.io
[terraform-aws-vpc]: /posts/terraform-aws-vpc.html
[k8s-gcloud]: /posts/kubernetes-terraform-google-cloud.html
[charity-terraform]: https://charity.wtf/tag/terraform/
[packer-book]: https://terraformbook.com
[travis-terraform]: https://github.com/travis-ci/terraform-config
[remote state]: https://www.terraform.io/docs/state/index.html
[state-purpose]: https://www.terraform.io/docs/state/purpose.html
[backend]: https://www.terraform.io/docs/backends
[Terraform Modules]: https://www.terraform.io/docs/modules/usage.html
[public registry]: https://registry.terraform.io
