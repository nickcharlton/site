---
title: Style Guide
---

## Style Guide

This page is a style guide for each and every element that will often be used
on this site. It covers most of the inline elements, as well as many content
specific block elements that usually come up on a site such as this.

---

First, headings:

# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6

Then blocks of text and code:

Often in blocks of text, you'll end up with things like footnotes[^1], or
blocks of code `main() { }`.

[^1]: This is a footnote.

```c
void main(void) {
  printf("Hello World!");
  return 0;
}
```

Quotes are also a useful feature to insert:

> A quote from someone &mdash; Anonymous

After that, lists and tables:

1. One
2. Two

* Item
* Item

| Heading 1 | Heading 2 |
|-----------|-----------|
| Data 1    | Data 2    |

Then media blocks:

<figure>
  <img src="http://placekitten.com.s3.amazonaws.com/homepage-samples/408/287.jpg" alt="A Cat Picture">
  <figcaption>A Cat Picture.</figcaption>
</figure>

And that's a wrap.
