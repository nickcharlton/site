---
title: An Ultra-simple Guide to Reading XML in Java, using SAX
tags: java xml sax
---

For the piece of work I have been dealing with recently, I was required to implement persistence using XML in Java. I figured this would be simple. Java and XML are used all the time, right? Should be easy.

However, after reading various bits of writing on the subject, from [Chapter 5 of Java and XML](http://www.cafeconleche.org/books/xmljava/chapters/ch05.html) to this O'Reilly OnJava article on [Simple XML Parsing with SAX and DOM](http://onjava.com/pub/a/onjava/2002/06/26/xml.html), as suggested by [Chris](http://www.chrisbunney.com/), it still didn't cut the ultra simplicity I wanted to Just Get the Damn Thing Done™.

Sample XML File
---------------

For this example, I'm just going to show you how to deal with a single element inside an XML document. Obviously, in the real world, it wouldn't be this simple, but it should be enough to provide the understanding you need.

	<?xml version="1.0"?>
	<people>
		<person>
			<age>50</age>
		</person>
	</people>

Opening the File
----------------

The block below opens up the file, parses it's contents, then closes it back up. It does this by opening up the file in a stream, then passing this stream into the SAX parser. 

	import java.io.*;
	import org.xml.sax.*;
	import org.xml.sax.helpers.*;

	public class SAXClient {
	    public static void main(String[] args) {
	        try {
	            // specify the SAXParser
	            XMLReader parser = XMLReaderFactory.createXMLReader(
	                "com.sun.org.apache.xerces.internal.parsers.SAXParser"
	            );
	            // setup the handler
	            ContentHandler handler = new Handler();
	            parser.setContentHandler(handler);
	            // open the file
	            FileInputStream in = new FileInputStream("file.xml");
	            InputSource source = new InputSource(in);
	            // parse the data
	            parser.parse(source);
	            // print an empty line under the data
	            System.out.println();
	            // close the file
	            in.close();
	        }
	        catch (Exception e) {
	            System.err.println(e); 
	        }
	    }
	}

Handling the Content
--------------------

We implement a class which extends the DefaultHandler, which handles what happens when it reaches each part of the XML document. 

When the handler reaches the start of the element, a flag is set to true. When it reaches the end of the tag, this flag is set to false. When it is inside the tag, the contents is printed out.

	import org.xml.sax.*;
	import org.xml.sax.helpers.DefaultHandler;

	public class Handler extends DefaultHandler {
	    private boolean inAge = false;

	    public void startElement(String namespaceURI, String localName, String qualifiedName, Attributes atts) throws SAXException {
	        if (localName.equals("age")) inAge = true;
	    }

	    public void endElement(String namespaceURI, String localName, String qualifiedName) throws SAXException {
	        if (localName.equals("age")) inAge = false;
	    }

	    public void characters(char[] ch, int start, int length) throws SAXException {
	        if (inAge) {
	            for (int i = start; i < start+length; i++) {
	                System.out.print(ch[i]); 
	            }
	        }
	    }
	}

To deal with the output, you'll need to implement some form of data structure to hold the data. A good tip that can be provided here is that the parser will follow from the top to the bottom when navigating your XML structure. This can be taken advantage of when dealing with the pending data.

