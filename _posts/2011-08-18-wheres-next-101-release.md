---
title: Where's Next? 1.0.1 Release
tags: wheresnext, app, project
---

After a bit of an issue with the original launch, _Where's Next?_ 1.0.1 has now been approved and is [in the App Store](http://itunes.apple.com/gb/app/wheres-next/id454450198?mt=8).

This fixes the crashing on load bug which ended up falling through testing (if you saw it, you'd have thought I didn't test it, but I did, but obviously not well enough).

For the those who are interested, it was a pointer to integer comparison that caused the problem. Oddly, it was not caught by GCC/LLVM. Unfortunately, that's one of the disadvantages of an unmanaged memory model.

But anyway. I'm pleased it is finally in the store.

