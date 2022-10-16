---
title: Building Custom Android ListViews
tags: android listview java
---

The documentation for Android's `ListView`'s is a little sparse. The examples around on the web are also not too great. This article intends to be the one I was searching for in trying to understand how to display some more advanced data, and deal with events.

## Introduction

`ListView`'s are the solution to most data problems on Android (much like `UITableView` is used extensively in iOS). However, they are a little undocumented. The rest of this article should allow you to go from having a basic `ListView`, to one much more complex and useful.

### The Project

This is implemented using Android 2.2, but it will work with more recent versions. These are the project settings used:

    Project name: HelloListView
    Build target: Android 2.2
    Application name: CustomListViews
    Package name: org.example.hellolistview
    Create Activity: HelloListView
    Min SDK Version: 8

### Prerequisites

Firstly, I assume you have tried building a basic `ListView` ([This tutorial is good for that](http://developer.android.com/resources/tutorials/views/hello-listview.html)). Secondly, I assume your data source is an `ArrayList`, containing objects for each element of data.

Once you have followed the basics of this guide, you will find that you can use the latter sections as you wish.

At 2010's Google IO, there was an hour long session which talked about `ListView`'s extensively, you may wish to watch that first. [You'll find it here](http://www.google.com/events/io/2010/sessions/world-of-listview-android.html).

## Building the Foundations

This starts with building a basic view which is backed onto an `ArrayList`. You can expand on the complexity from here.

### Extending ListActivity

The first step is to subclass `ListActivity` instead of `Activity`. This provides us with some functionality specific to lists. Of note, if we have no data we can easily provide an alternative. 

    public class HelloListView extends ListActivity {
        // ....
    }

### The View XML (main.xml, list_item.xml)

#### main.xml

    <?xml version="1.0" encoding="utf-8"?>
    
    <LinearLayout 
    	xmlns:android="http://schemas.android.com/apk/res/android"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent">
        
        <ListView 
        	android:id="@android:id/list"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content" />
        
        <TextView
        	android:id="@android:id/empty"
        	android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/empty" />
    </LinearLayout>

This defines the main view. It contains a layout which fills the screen, which in turn contains two subviews. The `ListView` defines the view, and the `TextView` is the backup which is called by `ListActivity` when there is no data to display.

#### list_item.xml

    <?xml version="1.0" encoding="utf-8"?>
    
    <LinearLayout 
    	xmlns:android="http://schemas.android.com/apk/res/android"
    	android:layout_width="wrap_content" 
    	android:layout_height="wrap_content" 
    	android:background="#000000">
    	<TextView 
    		android:layout_width="wrap_content"
    		android:layout_height="wrap_content" 
    		android:id="@+id/text">
    	</TextView>
    </LinearLayout>

This defines a very basic view. A screenshot is shown below. You do need to provide `android:layout_width` and `android:layout_height` declarations for each, otherwise it will not render.

<figure>
<img src="/resources/android-list-views/listview_foundations.png" alt="ListView Basics">
<figcaption>ListView Basics</figcaption>
</figure>

### Data Source and Adapter

To display what is shown in the screenshot above, the following code is used. It's not necessarily the most concise, but you should find it simple to follow.

#### HelloListView.java

    public class HelloListView extends ListActivity {
    	// define the data source
    	private ArrayList<String> data;
    	
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            
            // setup the data source
            this.data = new ArrayList<String>();
            
            // add some objects into the array list
            this.data.add("List Item 1");
            this.data.add("List Item 2");
            this.data.add("List Item 3");
            
            // use main.xml for the layout
            setContentView(R.layout.main);
            
            // setup the data adaptor
            ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, R.layout.list_item, R.id.text, this.data);
            
            // specify the list adaptor
            setListAdapter(adapter);
        }
    }

Here, we are creating the `ArrayList` holding our data set. Then we are adding the three elements we wish to display.

After this, we are setting up the `ArrayAdapter` to bridge the `ListView` to the dataset, and the specific item in the list.

The `ArrayAdaptor` translates the objects given to it (the last parameter) using a `.toString()`. This places the value inside the element with id `@+id/text` inside the `list_item.xml` file.

## Displaying Custom Objects

For the rest of this article, the `ListItem` class is going to be used to display inside the `ListView`. This contains two members, title and subtitle. This is enough to show off using a custom adaptor.

### ListItem.java

    /*
    * Defines a simple object to be displayed in a list view.
    */
    package org.example.HelloListView;
    
    public class ListItem {
    	public String title;
    	public String subTitle;
    	
    	// default constructor
    	public ListItem() {
    		this("Title", "Subtitle");
    	}
    	
    	// main constructor
    	public ListItem(String title, String subTitle) {
    		super();
    		this.title = title;
    		this.subTitle = subTitle;
    	}
    	
    	// String representation
    	public String toString() {
    		return this.title + " : " + this.subTitle;
    	}
    }

There are also a few changes to be made to the rest of the project to get this to work.

### HelloListView.java

    // setup the data source
    this.data = new ArrayList<ListItem>();
    
    // add some objects into the array list
    ListItem item = new ListItem("Hello", "Nick");
    this.data.add(item);

You will also need to change any references to `ArrayList<String>` to `ArrayList<ListItem>`.

By default, this will still display in the current incarnation. This is because we're simply outputting a string representation of the object. To display more complex information, the [SimpleAdaptor class](http://developer.android.com/reference/android/widget/SimpleAdapter.html) can render checkable objects (like a `CheckBox`), Strings and Images. Anything more complicated would require building a custom data adaptor.

<figure>
<img src="/resources/android-list-views/listview_custom_object.png" alt="ListView Custom Object">
<figcaption>ListView Custom Object</figcaption>
</figure>

## Complex ListViews with SimpleAdapter

SimpleAdapter can be used for building more complex `ListViews`. Compared to the `ArrayAdapter` class, SimpleAdaptor takes a few more arguments to map more data to more views.

Unfortunately, SimpleAdapter requires a collection of Maps to define the data. There are two ways to put together the objects wanted, the first is to create all new objects, and the second is to build a simple wrapper around Map on our original `ListItem` class. The former is shown below:

### Creating new Objects

#### HelloListView.java

    public class HelloListView extends ListActivity {
    	// define the data source
    	private ArrayList<Map> data;
    	
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            
            // setup the data source
            this.data = new ArrayList<Map>();
            
            // add some objects into the array list
            Map m = new HashMap();
            m.put("title", "Hello");
            m.put("subtitle", "Nick");
            
            this.data.add(m);
            
            // use main.xml for the layout
            setContentView(R.layout.main);
            
            // setup the data adaptor
            String[] from = {"title", "subtitle"};
            int[] to = {R.id.title, R.id.subtitle};
            SimpleAdapter adapter = new SimpleAdapter(this, (List<? extends Map<String, ?>>) this.data, R.layout.list_item, from, to);
            
            // specify the list adaptor
            setListAdapter(adapter);
        }
    }

#### list_item.xml

    <?xml version="1.0" encoding="utf-8"?>
    
    <LinearLayout 
    	xmlns:android="http://schemas.android.com/apk/res/android"
    	android:layout_width="wrap_content" 
    	android:layout_height="wrap_content" 
    	android:background="#000000">
    	
    	<TextView 
    		android:layout_width="wrap_content"
    		android:layout_height="wrap_content" 
    		android:id="@+id/title">
    	</TextView>
    	
    	<TextView 
    		android:layout_width="wrap_content"
    		android:layout_height="wrap_content" 
    		android:id="@+id/subtitle">
    	</TextView>
    		
    </LinearLayout>

Here, we are creating a new object (which is a Map), and placing this into our collection. This is then passed into `SimpleAdapter`.

### Extending Map

By extending Map, we can adjust our `ListItem` class to appear to be a Map. Here, we will use the members of the class as the key, and their values, as the values.

#### ListItem.java

    public class ListItem implements Map<String, String> {
    	public String title;
    	public String subTitle;
    	
    	// default constructor
    	public ListItem() {
    		this("Title", "Subtitle");
    	}
    	
    	// main constructor
    	public ListItem(String title, String subTitle) {
    		super();
    		this.title = title;
    		this.subTitle = subTitle;
    	}
    	
    	// String representation
    	public String toString() {
    		return this.title + " : " + this.subTitle;
    	}
    	
    	// Map interface classes
    	
    	// return a count of our members
    	public int size() {
    		return 2;
    	}
    	
    	// set the values of the object to null
    	public void clear() {
    		this.title = null;
    		this.subTitle = null;
    	}
    	
    	// return all of the values as a collection
    	public ArrayList<String> values() {
    		ArrayList<String> list = new ArrayList<String>();
    		
    		list.add(title);
    		list.add(subTitle);
    		
    		return list;
    	}
    	
    	// if the values of the members are null, return true
    	public boolean isEmpty() {
    		if ((this.title == null) && (this.subTitle == null)) {
    			return true;
    		} else {
    			return false;
    		}
    	}
    	
    	// return a set of the members
    	public Set<String> keySet() {
    		Set<String> s = new HashSet<String>();
    		
    		s.add("title");
    		s.add("subTitle");
    		
    		return s;
    	}
    	
    	// return a set of the member values
    	public Set entrySet() {
    		Set<String> s = new HashSet<String>();
    		
    		s.add(this.title);
    		s.add(this.subTitle);
    		
    		return s;
    	}
    	
    	// return the value of the given key
    	public String get(Object key) {
    		if (key.equals("title")) {
    			return this.title;
    		}
    		if (key.equals("subTitle")) {
    			return this.subTitle;
    		}
    		// if we can't return a value, throw the exception
    		throw new ClassCastException();
    	}
    	
    	// set the value of a given key
    	public String put(String key, String value) {
    		if (key.equals("title")) {
    			this.title = value;
    		}
    		if (key.equals("subTitle")) {
    			this.subTitle = value;
    		}
    		return value;
    	}
    	
    	// remove a key (nullify)
    	public String remove(Object key) {
    		String value = null;
    		if (key.equals("title")) {
    			value = this.title;
    			this.title = null;
    		}
    		if (key.equals("subTitle")) {
    			value = this.subTitle;
    			this.subTitle = null;
    		}
    		return value;
    	}
    	
    	// return boolean if we have a member
    	public boolean containsKey(Object key) {
    		if (key.equals("title")) {
    			return true;
    		}
    		if (key.equals("subTitle")) {
    			return true;
    		}
    		return false;
    	}
    	
    	// return boolean if we have a member's value
    	public boolean containsValue(Object value) {
    		if (value.equals(this.title)) {
    			return true;
    		}
    		if (value.equals(this.subTitle)) {
    			return true;
    		}
    		return false;
    	}
    
    	// set the values of this map to that of another
    	public void putAll(Map<? extends String, ? extends String> arg0) {
    		// we only need the stub.
    	}
    	
    }

This implements all of the methods required by the [Map interface](http://download.oracle.com/javase/6/docs/api/java/util/Map.html). You may not need all of them to support SimpleAdapter. I'd suggest subclassing the class above, and making this abstract. Then you can implement just what you need.

In `HelloListView.java`, the original object, then map declarations can then be replaced with:

    // add some objects into the array list
    ListItem item = new ListItem("Hello", "Nick");
        
    this.data.add(item);

The view will then look like the previous screenshot.

## Creating a Custom Data Adaptor

`ArrayAdapter` provides a simple way to add an array of strings to a `ListView`. `SimpleAdapter` provides a way to specify a more complex object (mostly containing strings) and place those into a `ListView`.

However, if you want to do anything more complicated you need to roll your own Adaptor. The Data Adaptor provides the link between the data and the View. It implements the methods of `BaseAdapter` to provide what is needed by the `ListView`. Here, we are assuming that you wish to stick with XML for layout (it's the suggested way). If you wish to do it just in code, [here's an example](http://www.anddev.org/novice-tutorials-f8/checkbox-text-list-extension-of-iconified-text-tutorial-t771.html).

_For this section, we are starting again with the basic list view implemented earlier._

### HelloListView.java

    public class HelloListView extends ListActivity {
    	private ArrayList<ListItem> data;
        /** Called when the activity is first created. */
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.main);
            
            // setup the data source
            this.data = new ArrayList<ListItem>();
            
            // create some objects
            ListItem item1 = new ListItem("Title", "Subtitle");
            
            // add them into the array list
            this.data.add(item1);
            
            // use main.xml for the layout
            setContentView(R.layout.main);
            
            // setup the data adaptor
            CustomAdapter adapter = new CustomAdapter(this, R.layout.list_item, this.data);
            
            // specify the list adaptor
            setListAdapter(adapter);
        }
    }

### CustomAdapter.java

    public class CustomAdapter extends BaseAdapter {
    	// store the context (as an inflated layout)
    	private LayoutInflater inflater;
    	// store the resource (typically list_item.xml)
    	private int resource;
    	// store (a reference to) the data
    	private ArrayList<ListItem> data;
    	
    	/**
    	 * Default constructor. Creates the new Adaptor object to
    	 * provide a ListView with data.
    	 * @param context
    	 * @param resource
    	 * @param data
    	 */
    	public CustomAdapter(Context context, int resource, ArrayList<ListItem> data) {
    		this.inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    		this.resource = resource;
    		this.data = data;
    	}
    	
    	/**
    	 * Return the size of the data set.
    	 */
    	public int getCount() {
    		return this.data.size();
    	}
    	
    	/**
    	 * Return an object in the data set.
    	 */
    	public Object getItem(int position) {
    		return this.data.get(position);
    	}
    	
    	/**
    	 * Return the position provided.
    	 */
    	public long getItemId(int position) {
    		return position;
    	}
    
    	/**
    	 * Return a generated view for a position.
    	 */
    	public View getView(int position, View convertView, ViewGroup parent) {
    		// reuse a given view, or inflate a new one from the xml
    		View view;
    		 
    		if (convertView == null) {
    			view = this.inflater.inflate(resource, parent, false);
    		} else {
    			view = convertView;
    		}
    		
    		// bind the data to the view object
    		return this.bindData(view, position);
    	}
    	
    	/**
    	 * Bind the provided data to the view.
    	 * This is the only method not required by base adapter.
    	 */
    	public View bindData(View view, int position) {
    		// make sure it's worth drawing the view
    		if (this.data.get(position) == null) {
    			return view;
    		}
    		
    		// pull out the object
    		ListItem item = this.data.get(position);
    		
    		// extract the view object
    		View viewElement = view.findViewById(R.id.title);
    		// cast to the correct type
    		TextView tv = (TextView)viewElement;
    		// set the value
    		tv.setText(item.title);
    		
    		viewElement = view.findViewById(R.id.subTitle);
    		tv = (TextView)viewElement;
    		tv.setText(item.subTitle);
    		
    		// return the final view object
    		return view;
    	}
    }

### list_item.xml

    <?xml version="1.0" encoding="utf-8"?>
    
    <LinearLayout 
       	xmlns:android="http://schemas.android.com/apk/res/android"
       	android:layout_width="wrap_content" 
       	android:layout_height="wrap_content" 
       	android:background="#000000">
       	<TextView 
       		android:layout_width="wrap_content"
       		android:layout_height="wrap_content" 
       		android:id="@+id/title">
       	</TextView>
       	<TextView 
       		android:layout_width="wrap_content"
       		android:layout_height="wrap_content" 
       		android:id="@+id/subTitle">
       	</TextView>
    </LinearLayout>

The same source as above was used for the `ListItem` class. 

The `bindData` method is where the most customisation will be required. This extracts the given view objects (the XML TextView, in this case), and binds the value of the members to it. Here, we have just used TextViews, but something similar would be used for other parts of the view.

## Handling Events

### Single Taps

The most obvious case for handling events is handling when a user taps (or clicks) a row. To do this, you define the `onItemClick()` method, and then inside this you can extract the original object back out to do stuff with it.

        ListView lv = getListView();
        lv.setTextFilterEnabled(true);

        lv.setOnItemClickListener(new OnItemClickListener() {
          public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        	  // When clicked, show a toast with the TextView text
        	  Toast.makeText(getApplicationContext(), parent.getItemAtPosition(position).toString(),
                Toast.LENGTH_SHORT).show();
          }
        });

This defines the on `onItemClick()` method for handling the event. When a user taps on the item, it prints out the string representation of the object. It uses ["Toast", Android's discrete notifications class](http://developer.android.com/reference/android/widget/Toast.html).

The important call is `parent.getItemAtPosition(position)`. This extracts the selected object from the `ListAdapter`.

### Long Taps

"long taps" are perceived to be the equivalent to right-clicks on the desktop. On a list item, you would take this to mean a desire for more information about an item.

Implementing `LongClick` is much the same as normal clicks (taps). The difference is merely in the method calls which are defined:

    lv.setOnItemLongClickListener(new OnItemLongClickListener() {
        public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
          	  // When clicked, show a toast with the TextView text
          	  Toast.makeText(getApplicationContext(), "You long clicked on: " + parent.getItemAtPosition(position).toString(),
                  Toast.LENGTH_SHORT).show();
          	  
          	  return true;
        }
    });

## Adjusting Data in the View

This is a bit of a hack. The intention here is to show how to add and notify the adaptor of changes, rather than suggest a good way to go about doing it.

### Adding New Data

The simplest way to demonstrate this is to make the list item duplicate itself on tap (or click). Add the following before the `Toast` declarations, and the data model will be updated:

    // on press, duplicate the object
    ListItem item = (ListItem)parent.getItemAtPosition(position);
    ListItem newItem = new ListItem(item.title, item.subTitle);
    data.add(newItem);

The next step is to notify the `ListView` that the data is invalid. This will reload the data from the data model, and the new object will appear.

    // get the adaptor
    SimpleAdapter adapter = (SimpleAdapter)parent.getAdapter();
    adapter.notifyDataSetChanged();

The same goes for handling editing and deleting functions on the underlying data. You just need to make sure you keep adjust the data set, and keep the adapter informed - then the most recent data is both saved and displayed.

## Code

For each of the sections in this article, I have put together a set of examples. They are Zip archives of the Eclipse projects which were created whilst I was writing this.

The projects are targeted at Android 2.2, and were used with Eclipse 3.5.2 (Helios). The code is licensed under the MIT license.

[You can find the code here](http://nickcharlton.net/resources/android-list-views/code.zip).

## Further Reading

To move along from here, I would suggest reading Chapter 9 (Putting SQL to Work) of [Hello, Android (3rd Edition) by Ed Burnette](http://www.amazon.co.uk/gp/product/1934356565/ref=as_li_ss_tl?ie=UTF8&tag=nisbl-21&linkCode=as2&camp=1634&creative=19450&creativeASIN=1934356565). This provides a basic introduction to ListViews, but more importantly talks about hooking up a `ListView` to [SQLite](http://www.sqlite.org/).

As mentioned earlier, the [basic ListView tutorial](http://developer.android.com/resources/tutorials/views/hello-listview.html) and the [ListActivity Class Reference](http://developer.android.com/reference/android/app/ListActivity.html) should also be of use to you.

## Conclusion

Android's `ListView` is pretty powerful, unfortunately, the documentation isn't go great. Hopefully this will give people new to Android a kick-start in using the `ListView`.

Thanks to [Paul Hallet](http://phalt.co.uk/) for reviewing this before posting.

