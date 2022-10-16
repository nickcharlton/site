---
title: Introduction to SQLite 2 with PHP 5
tags: php, sqlite
---

Where a full <acronym title="Relational Database Management System">RDBMS</acronym> is unnecessary, [SQLite](http://www.sqlite.org/) provides the perfect stand in. However, most articles are based around the Object-Orientated way of dealing with SQLite in PHP. This article provides an explanation of how to use it procedurally.

### Points

A couple of things to note before going ahead and using SQLite are that:

* The directory and the database need to be writable from the web server.</li>
* As it is simply a flatfile, this should be stored where it cannot be accessed by browsers.
* Where an "auto_increment" field is used in MySQL, it should be created by specifying "INTEGER PRIMARY KEY" when configuring the table. This is further explained later.

### Opening a SQLite DB

Opening an SQLite Database is quite simple. The "sqlite_open" function is assigned to a variable which is then used to indicate that database later on in queries. If the database does not already exist then it will be created upon opening.

The file extension need not be .db, it may be anything, or even have none. The directory which is referenced should be both outside of the web root and writable by the server user. On Debian Etch with Apache, the user is "www-data".

	$db = sqlite_open("../db/name.db");

### Creating a table

Before data can be written or read to a Database, a table needs to be created to hold it. The the line below runs a CREATE query which describes the table which will be created. Whilst I do not wish to explain how to use SQL in this article, the following creates a table with two fields, one (called "id") which automatically increments in regards to it's value and is set as a primary key and the second, called "name" containing text of up to 255 characters. The table itself is called "example". The [SQLite Documentation](http://www.sqlite.org/lang.html) provides a good guide behind the syntax.

	sqlite_query($db, "CREATE TABLE example (id INTEGER PRIMARY KEY, name CHAR(255))");

### Inserting data

To insert data, the "sqlite_query" function is used which specifies the database in the first part, and then the query behind it.

The query in this example inserts the name "Nick" into the field "name" in the table "example". As the field "id" auto increments, it is not necessary to specify a value for it.

	sqlite_query($db, "INSERT INTO example (name) VALUES ('Nick')");

### Querying data

The following line would fetch all of the data in the table "example" and display it as a "printed array".


	$result = sqlite_query($db, "SELECT * FROM table");
	while ($row = sqlite_fetch_array($result)) {
		echo "<pre>";
		print_r($row);
		echo "</pre>";
	}

On an alternative note, such a method can be used to see the contents of a query and check the names of fields, at least in development.

### Further Reading

Whilst this article focuses on the procedural method built into PHP 5 (which incidentally is limited to SQLite 2), SQLite can also be accessed through <acronym title="PHP Data Objects">PDO</acronym> and through the Object Orientated Method.

* [PHP Manual: SQLite](http://php.net/sqlite)
* [Object Orientated SQLite, Devshed](http://www.devshed.com/c/a/PHP/Introduction-to-Using-SQLite-with-PHP-5/)
* [SQLite 3 with PDO, Zend DevZone](http://devzone.zend.com/article/863)

