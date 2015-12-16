---
title: Drawing Primitives with Quartz
published: 2011-11-26 23:13:28 +0000
tags: drawing, graphics, quartz, iOS, macosx
---

I've always found drawing graphics complicated. Not that because maths is involved (that's the good bit), but finding simple examples to work out what the hell is going on. Usually, the calls required are a little different, and required to ensure something actually gets drawn &mdash; Quartz is no different. This intends to serve as a few notes on using the basics of QuartzCore, the drawing tools present in iOS and on Mac OS X. 

Most of the calls are just C, but the example (linked at the bottom) shows all of the examples drawn inside a UIView on iOS. The rest of this assume you know what I have just written, and what `CGRectMake()` does. 

## Requirements

You need to add the `QuartzCore` framework to your project in Xcode. Then you need to import the headers in relevant files. All that is required for the examples here is: `#import <QuartzCore/QuartzCore.h>`.

## A Bit of Theory

Quartz works similar to a pen on paper, especially for lines and rectangles. Much like picking the right type of pen before making marks on paper, Quartz works in a similar way. Changing the attributes of lines (the pen) is done just before drawing. Drawings also layer in a similar manner. If you tell Quartz to draw over a point that you have already drawn on, it will be layered on top of it.

    // get the initial context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // save the current state, as we'll overwrite this
    CGContextSaveGState(context);
    
    // draw stuff
    
    // do the actual drawing
    CGContextStrokePath(context);
    
    // restore the state back after drawing on it.
    CGContextRestoreGState(context);

The rest of these examples assume the above. This gets the current drawing context (in this case, the UIView we are going to draw onto, but this could be almost anything, including a PDF). It saves the current state, as this is what we'll be accessing.

After the drawing statements, we proceed to do the actual drawing, and then save it back to the context we were working with. This then renders the drawing on the relevant view.

## Lines

The simplest primitive to draw is a line. These (and arcs) make up the majority of work done with Quartz. It also fits the best within the real-world drawing metaphor.

First, you need to position the pen, then you can draw a line to the next coordinate:

    // move the pen to the starting point
    CGContextMoveToPoint(context, 10, 10);

    // draw a line to another point
    CGContextAddLineToPoint(context, 290, 10);

This starts at position 10, 10 and draws a line parallel to the top of the view to the other side. It looks like this:

![A line drawn on a UIView](http://nickcharlton.net/resources/drawing-primitives/line.png)

**The pixels are relevant to the view they are created in.** So, drawing to 100, 100 would draw a line at a 45&deg; angle pointing down towards the middle of the view.

## Styling

* By default, a line is 1px thick. You can change this by setting the second parameter of: `CGContextSetLineWidth(context, 5)`.
* To set the colour: `CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);`. Where the numbers are RGBA values.
* By default, the stroke straddles both sides of the line. If you're positioning elements with a 5px stroke, you will want to offset the position by 2.5px.
* Each call to `CGContextStrokePath(context);` commits the drawing to the canvas. If you want to set different styling for different elements, you need to commit it first. Then 'pick up the pen' with the next element.

## Rectangles

For shapes, the position is based upon a CGRect. This makes it handy for colouring the position of elements if you are drawing/comparing more complex shapes. This also means that it doesn't use the notion of a pen.

    CGContextAddRect(context, CGRectMake(10, 20, 280, 30));

This would draw a rectangle just below the line, 30px high. Rectangles are rendered from their origin point (top left corner) and drawn out from there. 

![A box drawn on a UIView](http://nickcharlton.net/resources/drawing-primitives/box.png)

## Circles

Circles (also called arcs and ellipses) are more complicated. There are two ways to define a complete circle, and various other ways to define different types of arc &mdash; including Bézier curves. The snippet below just describes circles, however:

The simplest way to define a circle is placing one inside a `CGRect`. The circle will be drawn to fit the best it can inside the rectangle.

    CGContextAddEllipseInRect(context, CGRectMake(50, 70, 200, 200));

This will draw a circle with 200px in diameter below the other elements.

![A circle drawn on a UIView](http://nickcharlton.net/resources/drawing-primitives/circle.png)

## Memory Management

Assuming you are not using ARC, the general rules apply from Core Foundation:

* If you call a function that has 'Create' or 'Copy' in the name, it's yours.
* If you get an object from elsewhere you don't own it, unless you explicitly retain it.
* And to release you should call `CFRelease`.

## Example Project

You can [download an example project here](http://nickcharlton.net/resources/drawing-primitives/project.zip). It contains the examples above, but put all into a single view. The object of importance is `PrimitivesView`. This provides the drawing, the rest is just a simple FlipSideViewController based project using Storyboards and ARC (for ease.) The [repository is also on GitHub](http://github.com/nickcharlton/DrawingPrimitives).

