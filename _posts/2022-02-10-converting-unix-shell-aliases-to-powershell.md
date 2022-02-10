---
title: "Converting Unix Shell Aliases to PowerShell"
published: 2022-02-23T14:48:01Z
tags: powershell unix windows shell scripts
---

I've been using Windows a lot recently and have been quite enjoying it. Some
things are new, but most are old and familiar. But after using a lot of shell
aliases over the last decade of using Linux & macOS, I needed them to come
over with me. I've been using [PowerShell][1] 7, inside [Windows Terminal][2]
(and mostly [VS Code][3] as the editor), and so far have pulled over my
[Git aliases][4]. If you're trying to bring over your own, this should be
enough to get you going.

PowerShell has an equivalent profile configuration file which can be found in:

```
C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

…and available as `$profile`. From here, you can configure aliases and
functions which are loaded across each session.

There's a couple of nuances in converting existing aliases to PowerShell
though, as an example I'm converting the following which covers all of the
cases I've seen so far:

In Unix Shell:

```sh
alias gws='git status -sb'
alias gl='gll -20'
alias gll="git log --pretty='format:%C(yellow)%h %C(blue)%ad %C(reset)%s%C(red)%d %C(green)%an%C(reset), %C(cyan)%ar' --date=short"
```

In PowerShell:

```powershell
function Get-GitStatus { git status -sb $args }
function Get-GitLog([string] $limit)  {
  git log --pretty='format:%C(yellow)%h %C(blue)%ad %C(reset)%s%C(red)%d %C(green)%an%C(reset), %C(cyan)%ar' --date=short $limit
}

function Get-GitLogShort {
  Get-GitLog '-20'
}

Set-Alias gws Get-GitStatus
Set-Alias gl Get-GitLogShort
Set-Alias gll Get-GitLog
```

Notably, [aliases][6] don't expand in place, which means you can't
automatically chain additional arguments. To do this, we need to use a
`function` to wrap what we like to do and then use `$args`
([a special argument equivalent to `$@`][5]) to capture anything further. This
is also the case if we want to be explicit about
[requiring further arguments][9], too.

By convention, [functions are named `Verb-Noun`][7]. I'm using a separate call
to [`Set-Alias`][8] to replicate the original pattern I'm copying, but there is
a way to [define these directly on functions][10].

This is my current `$profile`, which is not without the occasional problem, but
is working well so far:

```powershell
function Get-Git {
  ($isGit = git symbolic-ref HEAD) > $null

  if ($isGit) {
    $time_since_last_commit = git log -1 --pretty=format:"%ar"
    Write-Output "Last commit: ${time_since_last_commit}"
    git status --short --branch $args
  }
}

function Get-GitStatus { git status -sb $args }
function Get-GitBranch { git branch -vv $args }
function New-GitCommit { git commit --verbose $args }
function New-GitCommitAll { git commit --verbose --all $args }
function New-GitFixupCommit { git commit --fixup HEAD $args }
function New-GitCheckout { git checkout $args }
function New-GitAddition { git add $args }
function New-GitPush { git push $args }
function New-GitForcePush { git push --force-with-lease $args }
function New-GitRebase { git rebase $args }
function New-GitStash { git stash $args }
function Get-GitDiff { git diff --no-ext-diff $args }
function Get-GitLog([string] $limit)  {
  git log --pretty='format:%C(yellow)%h %C(blue)%ad %C(reset)%s%C(red)%d %C(green)%an%C(reset), %C(cyan)%ar' --date=short $limit
}

function Get-GitLogShort {
  Get-GitLog '-20'
}

Set-Alias g Get-Git
Set-Alias gws Get-GitStatus
Set-Alias gb Get-GitBranch
Set-Alias -Name gc -Value New-GitCommit -Force
Set-Alias gca New-GitCommitAll
Set-Alias gcf New-GitFixupCommit
Set-Alias gco New-GitCheckout
Set-Alias gia New-GitAddition
Set-Alias -Name gp -Value New-GitPush -Force
Set-Alias gpf New-GitForcePush
Set-Alias gr New-GitRebase
Set-Alias gs New-GitStash
Set-Alias gwd Get-GitDiff
Set-Alias -Name gl -Value Get-GitLogShort -Force
Set-Alias gll Get-GitLog
```

[1]: https://github.com/PowerShell/PowerShell
[2]: https://github.com/Microsoft/Terminal
[3]: https://github.com/microsoft/vscode
[4]: https://github.com/nickcharlton/dotfiles/blob/cead1b533bc154e0810197afeb33e5143f4ee4de/aliases#L10-L31
[5]: https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_03_02.html
[6]: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.2
[7]: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-7.2
[8]: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-alias?view=powershell-7.2
[9]: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-7.2#functions-with-parameters
[10]: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.2#alias-attribute
