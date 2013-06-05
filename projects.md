---
title: Projects
---

## Projects

<div id="grid">
  <div> 
    <h2><img class="project_icon" src="resources/projects/wheres_next_icon.png">Where's Next?</h2>    
    <p>Get your errands in order. Location order. For iPhone.</p>
    <ul>
      <li><a href="http://itunes.apple.com/gb/app/wheres-next/id454450198?mt=8">App Store</a></li>
    </ul>
  </div>
  <div>
    <h2><img class="project_icon" src="resources/projects/predict_the_sky_icon.png">Predict the Sky</h2>
    <p>What will you be able to see in the sky tonight? A byproduct of the Space Apps Challenge. Coming Soon.</p>
    <ul>
      <li><a href="http://nickcharlton.net/post/nasa-space-apps-challenge-predict-the-sky">Blog Post</a></li>
    </ul>
  </div>
</div>

### Others

Below is a collection of miscellaneous, interesting projects. Consider it as a bit 
of a portfolio (some are open source, some were freelance).

#### [BioOS][]: Android, IOIO and a Heart Rate Monitor

I jumped in at the end of this project to help with the finer bits of the [IOIO][] 
and [Heart Rate Monitor][hmri] implementation. The IOIO is a bit of an odd beast; 
it's a USB and Bluetooth connectable board for Android devices which allows you to 
communicate with electronics projects. I got the drivers working, and then dealt 
with the heart rate monitor itself. I also wrote a much more detailed 
[blog post about the difficult bits][ioio_post].

#### [omniauth-pam][]

[OmniAuth][] is an authentication system for Ruby web projects (it's [Rack][] 
middleware). It supports plugins for different authentication schemes and this is 
one of them. It adds the ability to authenticate against [PAM][], the login system 
used on many Linux distributions. It was recently updated to allow it to be used 
with [GitLab][]

[omniauth-pam]: https://github.com/nickcharlton/omniauth-pam
[OmniAuth]: https://github.com/intridea/omniauth
[Rack]: http://rack.github.io
[PAM]: http://en.wikipedia.org/wiki/Pluggable_authentication_module
[GitLab]: http://gitlab.org
[BioOS]: https://github.com/i-DAT/Bio-OS-Android
[IOIO]: https://github.com/ytai/ioio/wiki
[HMRI]: https://www.sparkfun.com/products/8661
[ioio_post]: #

