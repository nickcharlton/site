---
title: "Running PowerShell scripts locally with Packer"
tags: packer powershell
---

I maintain a set of virtual machine templates that use [Packer][4]. For
[VMware][5] VMs, the workflow is to build them locally using the `vmware-iso`
builder, then push to vSphere using the `vsphere` post-processor. The idea
behind this approach is to be able to use the same templates for local VMs
(which are exported as an `ova` archive) as those that end up on vSphere.
Unfortunately, there's some differences between VMware Workstation and vSphere
that create some tricky problems like mismatched operating system versions.

Fortunately, [PowerCLI][6] exists which makes it fairly pleasant to work with
vSphere from PowerShell. Packer can run local scripts, so I hatched the plan to
run a PowerShell script (using the `shell-local` provisioner) that would adjust
settings after the build had run. Alas, this is one of those problems that took
many months of evenings to figure out how to do.

I'm using Packer v1.11.2 and PowerShell 7.4.4, and running everything on Linux.
Here's an example that works, and an explanation of how it got here below:

```pwsh
# hello-world.ps1
Write-Output "Hello world!"

Write-Output $env:MY_VAR
Write-Output $env:WITH_SPACES
Write-Output $env:PACKER_BUILDER_TYPE
Write-Output $env:PACKER_BUILD_NAME

Write-Output "and done!"
```

```hcl
# example.pkr.hcl
source "null" "example" {
  communicator = "none"
}

build {
  source "source.null.example" {}

  provisioner "shell-local" {
    env                = {
      "MY_VAR": "hi",
      "WITH_SPACES": "and again"
    }

    execute_command    = ["pwsh", "-Command", "& { {{.Vars}} {{.Script}} }"]
    env_var_format     = "$env:%s=\"%s\"; "
    script             = "hello-world.ps1"
  }
}
```

```sh
$ packer build example.pkr.hcl
null.example: output will be in this color.

==> null.example: Running local shell script: hello-world.ps1
    null.example: Hello world!
    null.example: hi
    null.example: hello world
    null.example: null
    null.example: example
    null.example: and done!
Build 'null.example' finished after 450 milliseconds 889 microseconds.

==> Wait completed after 450 milliseconds 927 microseconds

==> Builds finished. The artifacts of successful builds are:
--> null.example: Did not export anything. This is the null builder
```

* This example uses the "null" builder, as we just want to run a local file,
  it's really helpful for testing,
* Using ["shell-local"][2] we can execute a file on the local filesystem, which
  would usually default to a shell script (on a Unix),
* But, this can be any command, and there's a few options we can use to adjust
  how the command is put together,
* [Packer exposes the builder type and build name as environment variables][1]
  or anything set in `environment_vars` or `env`, which will be key to
  providing things like secrets to the script later on,
* Unfortunately, [PowerShell doesn't accept environment variables as
  arguments][3], and seems to fail when assigned ahead of the command (e.g.:
  `{{.Vars}} bash '{{.Path}}'` would usually work in an existing shell
  session),
* Instead we can use a PowerShell block (`{ }`), and use `&` in front to
  execute immediately,
* There's two key things this is doing to make this work reliably, first, we
  provide a different template to `env_var_format` so that the output is how
  PowerShell expects it's environment variables (and how it ends up in the
  block), secondly, we use `env` rather than `environment_vars` and provide a
  map of values as this means that the output is escaped correctly

[1]: https://developer.hashicorp.com/packer/docs/post-processors/shell-local#default-environmental-variables
[2]: https://developer.hashicorp.com/packer/docs/post-processors/shell-local
[3]: https://github.com/PowerShell/PowerShell/issues/3316
[4]: https://www.packer.io
[5]: https://www.vmware.com
[6]: https://docs.vmware.com/en/VMware-PowerCLI/index.html
