---
title: I forked QuickDialog
tags: ios, quickdialog, github, projects
---

A couple of weeks ago, [Eduardo Scoz (ESCOZ, Inc)](http://escoz.com/) released [QuickDialog](http://escoz.com/quickdialog-released/), a rather nice way of producing UITableView based dialog controls on iOS.

In my own projects, and some of those I've been working on [at work](http://nickcharlton.net/post/starting-at-rokk-media), I've wanted to be able to use QuickDialog to make development faster. Unfortunately, it requires Automatic Reference Counting, and I usually work on the current stable version of iOS.

Whilst I do think ARC is a good thing, I wanted to use QuickDialog now. So, I forked it and adjusted it where needed to make it compile under iOS 4.3 and the Xcode 4.1 toolchain without errors. 

It's not completely tested and I don't intend to closely track the original branch, nor actively maintain it once iOS 5 is released. But, it's there and working if you want it.

_Note: In the future, I intend to push changes back into the original QuickDialog (especially when I find I want different controls.)_

[You can get it over on GitHub](https://github.com/nickcharlton/QuickDialog/).

