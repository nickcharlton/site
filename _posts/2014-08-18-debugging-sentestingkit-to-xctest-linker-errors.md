---
title: Debugging SenTestingKit to XCTest Linker Errors in Upgraded Xcode Projects
tags: xcode testing sentestingkit xctest ios
---

There's a couple of (client) projects which I maintain which have been in
existence for quite a while (one still has full iOS 5 support and hopefully
we'll be able to drop that soon), but they're still well maintained and have
reasonable test suites that have followed them through rather well. Sadly,
Xcode can be a bit difficult and this time was no exception &mdash; although
it did take a long time before the issue was seen.

In this project, I had a situation where the original [SenTestingKit][] tests
had been upgraded to use [XCTest][], but now they were failing to build. It
looked to be a configuration error, so to come to the correct settings, I
compared a new project (so, created straight out of Xcode with nothing else)
and another project which was as new, but had [Cocoapods][] attached. This
allowed me to get the correct (well, current) configuration and apply it back
to the old project.

In the end, it appeared to have been caused by Xcode's automatic upgrader
(which I'd run back when I upgraded the project) having mangled the build
settings. Here's how I fixed it:

## Update the Framework Search Paths

The first set of errors related to the imported headers being missing, and
looked like:

```
ld: framework not found -XCTest
```

In the test target under Xcode 5, the Header Search Paths listing should have
looked like:

```
$(inherited)
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
```

![Updated Header Search Paths Listing](/images/upgraded_xcode_project_header_search_paths_listing.png)

## Switch the linker flag from SenTestingKit to XCTest

The next set of error messages related to the testing framework being missing
and looked like:

```
Undefined symbols for architecture i386 "_OBJC_CLASS_$_XCTestCase"
```

This was caused by the old `SenTestingKit` still being linked aginst, and the
solution to this was to switch the "Other Linker Flags" setting to:

```
-Objc -framework XCTest
```

![Updated Project Linker Flags](/images/upgraded_xcode_project_linker_flags.png)

---

Of course, by the time someone else comes across the same issue (or a similar)
one, the ideal configuration has likely changed somewhat. The trick to finding
the solution is to build new Xcode projects from the templates and compare
your configuration.

[SenTestingKit]: http://www.sente.ch/software/ocunit/
[XCTest]: https://developer.apple.com/library/ios/documentation/ToolsLanguages/Conceptual/Xcode_Overview/UnitTestYourApp/UnitTestYourApp.html#//apple_ref/doc/uid/TP40010215-CH21-SW1
[Cocoapods]: http://cocoapods.org
