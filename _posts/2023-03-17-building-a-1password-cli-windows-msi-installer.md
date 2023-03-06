---
title: "Building a 1Password CLI Windows MSI Installer"
tags: windows msi 1password
---

[1Password has a CLI tool][5] that's very helpful for integrating into things
like setup scripts and handling development secrets more securely.

Unfortunately, on Windows, there's no installer. Instead, [you're prompted to
extract an archive, create the destination directory and add it to your
PATH][9]. This is annoying once, impractical to do multiple times and enough of
a hurdle for others to be quite a pain, especially when you want to keep up to
date with the most recent version.

I'm sure 1Password will release one eventually, but for now, I've put together
a quick [project to make installers that you can find on GitHub][1]. [On the
releases page][2], you can find built versions for `i386` and `amd64`.

I'll keep these updated until 1Password releases their own, but please let me
know if you see any problems (and if you find them useful too)! I would like to
have these code signed eventually, but for now, that's not something I can do.

---

This project initially came out of a frantic evening back in December 2022
where I got caught up in trying to assemble a basic installer with [WiX
Toolset][3], initially inspired by trying to resolve an installation issue
where we’ve been [side-loading an enterprise UWP app][4]. Whilst there's much
more to do (and another blog post to go with that topic), assembling the
missing installer for the 1Password CLI seemed like an excellent first step.

I elected to use [WiX v3, instead of v4 as v3][6] has much better information
about it. Using v3 meant I wasn't also trying to understand how to build
installers at the same time as trying to understand a whole new version of a
tool along with the rest of the community, and there's a lot of "TODO: WiX v4
documentation is under development." in the docs, which wasn't too inspiring.

As installer projects go, it's pretty straightforward. There's two build
architectures defined, along with a set of platform-dependent variables
(in `Config.wxi`):

```xml
<?xml version="1.0" encoding="utf-8"?>
 <Include>
 <?if $(var.Platform) = x64?>
 <?define PlatformProductName = "1Password CLI (x64)"?>
 <?define PlatformUpgradeCode = "D7D4A655-76AB-45C9-B50F-0A8C1009E8F5"?>
 <?define PlatformProgramFilesFolder = "ProgramFiles64Folder"?>
 <?else ?>
 <?define PlatformProductName = "1Password CLI (x86)"?>
 <?define PlatformUpgradeCode = "E21CFAE2-49F0-489C-A069-437374D61DA5"?>
 <?define PlatformProgramFilesFolder = "ProgramFilesFolder"?>
 <?endif ?>
 </Include>
```

In the main `Product.wxs` file, first, the target directory is setup:

```xml
<Directory Id="TARGETDIR" Name="SourceDir">
    <Directory Id="$(var.PlatformProgramFilesFolder)">
        <Directory Id="INSTALLFOLDER" Name="1Password CLI" />
    </Directory>
</Directory>
```

Then a `ComponentGroup` is defined that places the executable (kept at the root
of the project) and sets up the environment variable:

```xml
<ComponentGroup Directory="INSTALLFOLDER" Id="ProductComponentGroup">
    <Component Id="cmp_op.exe" Guid="*">
        <?if $(var.Platform) = x64 ?>
        <File KeyPath="yes" Name="op.exe" Source="op_x64.exe" />
        <?else ?>
        <File KeyPath="yes" Name="op.exe" Source="op_x86.exe" />
        <?endif ?>
    </Component>
    <Component Id="cmp_EnvironmentVariable" Guid="46D0B3FB-60B3-4F08-A911-CC03F3907DC2" KeyPath="yes">
        <Environment Id="InstallPath"
            Name="Path"
            Value="[INSTALLFOLDER]"
            Action="set"
            System="yes"
            Part="last"
            Separator=";" />
    </Component>
    <Component Id="cmp_RegistryEntry" Guid="*">
        <RegistryKey Root='HKLM' Key='Software\[Manufacturer]\[ProductName]'>
            <RegistryValue KeyPath='yes' Type='string' Name='Install location' Value='[INSTALLFOLDER]' />
        </RegistryKey>
    </Component>
</ComponentGroup>
```

Compiling independently for each architecture builds an installer in
`1PasswordCliInstaller\bin\Release` with this setup.

[kurtanr][8]'s [WiXInstallerExamples][7] project was very helpful in trying to
put this together, and many more examples if you find yourself trying to do
something similar.

[1]: https://github.com/nickcharlton/1password-cli-msi-installer
[2]: https://github.com/nickcharlton/1password-cli-msi-installer/releases
[3]: https://wixtoolset.org
[4]: https://learn.microsoft.com/en-us/windows/uwp/enterprise/#msix-deployment
[5]: https://developer.1password.com/docs/cli/
[6]: https://wixtoolset.org/docs/fourthree/
[7]: https://github.com/kurtanr/WiXInstallerExamples
[8]: https://github.com/kurtanr
[9]: https://developer.1password.com/docs/cli/get-started#install
