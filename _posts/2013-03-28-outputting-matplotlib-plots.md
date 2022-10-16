---
title: Outputting Matplotlib Plots for the Web
tags: python matplotlib drawing
---

For the past few days, I've been working with Matplotlib and collecting together a 
bunch of notes on animation. It lead to my previous post, 
[Drawing and Animating Shapes with Matplotlib][prevpost]. In doing so, I realised 
I'd only embedded plots inside PDFs (when they weren't part of some sort of 
application) and so, whilst getting bitmap images out of Matplotlib is quite easy,
it's not so optimal for the web. I'd rather use SVGs.

But, Matplotlib was designed to produce plots for publications, and so it's centred 
around printing. And so we have to deal with DPIs, inches and boundary boxes and a
bit of configuration.

So, given the [basic sine wave plot below][scipylectures]:

```python
import numpy as np
import matplotlib.pyplot as plt

figure = plt.figure()
plt.subplot(111)

X = np.linspace(-np.pi, np.pi, 256, endpoint=True)
C, S = np.cos(X), np.sin(X)

plt.plot(X, C)
plt.plot(X, S)

plt.ylim([-1.0, 1.0])
plt.xlim([-3, 3])

figure.savefig('sine_wave_plot.svg')
```

<figure>
    <img src="/resources/images/sine_wave_plot.svg" width="500px" alt="Figure 1: A Simple Sine Wave">
    <figcaption>Figure 1: A Simple Sine Wave</figcaption>
</figure>

The last line handles saving in the simplest of forms. This gives us a standard
sized SVG file. A nice way to calculate the resulting size is below. This was helped
by [this Stack Overflow question about page sizes][sopagesize].

```python
dpi = figure.get_dpi()
size = figure.get_size_inches()
print "DPI: %i" % dpi
print "Size in inches: %i x %i" % (size[0], size[1])
print "Pixels: %i x %i" % (dpi * size[0], dpi * size[1])
```

Typical screen DPI is 72 (with print usually around 300), so that gives us the
scaling factor. But, there's no reason why this cannot be 100 and using this
gives more obvious result. We can then use the simple equation of: pixels &divide; 
DPI to figure out the inches. So, for a 700 x 650 image, you'd want to specify 7 x 
6.5 inches:

```python
figure.set_dpi(100)
figure.set_size_inches(7, 6.5)
```

The resulting inches measurement will be rounded to the nearest integer, but this
will still translate to pixels. So, a 7 x 6.5 inch image will report being 7 x 6,
even though in the example above it'll produce a 700 x 650 image.

To keep the aspect ratio correct, 50 pixels are added in the above example to take
into account the y axis. Notably, the plot dispayed with `show()` won't respect the
same aspect ratio as the saved file.

The next thing to look at is the border around the plot. The simplest thing to
configure is that of `tight_layout`. If turned on, this reduces the white border
around the outside of the plot. The same will be applied to each subplot. After
enabling this, you get Figure 2.

```python
figure.set_tight_layout(True)
```

<figure>
    <img src="/resources/images/sine_wave_plot_tight.svg" width="500px" alt="Figure 2: Sine Wave Plot with Tight Layout">
    <figcaption>Figure 2: Sine Wave Plot with Tight Layout</figcaption>
</figure>

And so, with a little bit of extra effort, it's quite possible to get perfectly
sized and positioned plots using `savefig`. Using SVG means that the file size is
relatively small and it can be scaled without losing quality &mdash; much nicer on 
Retina displays &mdash; and they can be embedded like any other image.

[prevpost]: /posts/drawing-animating-shapes-matplotlib.html
[sopagesize]: http://stackoverflow.com/questions/332289/how-do-you-change-the-size-of-figures-drawn-with-matplotlib
[scipylectures]: http://scipy-lectures.github.com/intro/matplotlib/matplotlib.html

