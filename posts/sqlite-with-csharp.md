---
title: SQLite, ADO.NET & CSharp
published: 2010-04-14T08:00:00Z
tags: dotnet, csharp, sqlite
---

### Introduction

For a project I wanted to use SQLite for dealing with it's data. I quite readily found [System.Data.SQLite](http://sqlite.phxsoftware.com/ "System.Data.SQLite"). But, then I needed to figure out how ADO.NET worked. This has resulted in these short notes, mostly compiled from O'Reilly's out of print, [ADO.NET in a Nutshell](http://oreilly.com/catalog/9780596003616/ "ADO.NET in a Nutshell - O'Reilly Media").

Most of the rest of these notes are general to ADO.NET, but with a few System.Data.SQLite specifics.

### Prerequisites

* You'll need the System.Data.SQLite.dll file.
* You'll need to reference it in the VS Solution.
* You'll need to include the namespace at the top of your code.

	using System.Data.SQLite;

### Connection String

The first stage is to connect to the DB and to do that you'll create a "Connection" using a ConnectionString. An example is below:

    // initialise the database
	SQLiteConnection con = new SQLiteConnection("Data Source=../../Database.sqlite");
	
### Opening

This simply opens the database connection. (See Closing for, ..closing).

	con.Open;
	
You can test the status of the connection by writing:

	Console.WriteLine("Connection is " + con.State.ToString());

### Queries and NonQueries

ADO.NET differentiates between "Queries" and "NonQueries". The difference is dependant on the returned data.

A "NonQuery" is an SQL statement such as "UPDATE", "DELETE" and "INSERT", as they do not return data. You will however get a count of how many rows were effected on execution.

### Command String

#### NonQueries

	// define our SQL.
	string SQL = "UPDATE people SET name='Someone Else' WHERE id=1";

    // Create the Command
	SQLiteCommand cmd = new SQLiteCommand(SQL, con);
	
	// Open the connection (if you haven't already).
	con.Open();
	
	// execute our command.
	int rowsAffected = cmd.ExecuteNonQuery();
	
First we define our SQL query (which is just a string), then instantiate the SQLiteCommand object, and finally run our command.

#### Returning a Single Result

The `ExecuteScalar()` method returns a single value. This would be used to return the result of a calculation. Such as requesting a COUNT.

	cmd.ExecuteScalar();
	
The returned value is an Object of the result.

Example:

    string SQL = "SELECT id FROM people WHERE id='1';";

	SQLiteCommand cmd = new SQLiteCommand(SQL, con);

	con.Open();

	object result = cmd.ExecuteScalar();
	int convert = Convert.ToInt16(result);

	con.Close();
	Console.WriteLine(convert.ToString() + " rows.");

#### Creating Tables

Creating tables is done in a similar way to the above, but with just a different SQL command. (So, I won't mention it here.)

#### Performing SELECTs / Using DataReader

The DataReader class provides the methods to iterate over rows in a database. So, this is the function to use to perform SELECT statements that return more than one record.

Example:

	string SQL = "SELECT ContactName FROM Customers";

    // Create ADO.NET objects.
    SQLiteConnection con = new SQLiteConnection("Data Source=../../Database.sqlite");
    SQLiteCommand cmd = new SqlCommand(SQL, con);
    SQLiteDataReader reader = null;

    // Execute the command.
    try
    {
        con.Open();
        reader = cmd.ExecuteReader();

        // Iterate over the results.
        while (reader.Read())
        {
            lstNames.Items.Add(reader["ContactName"]);
        }
    }
    catch (Exception err)
    {
        MessageBox.Show(err.ToString());
    }
    finally
    {
        if (reader != null) reader.Close();
        con.Close();
    }

You can also run more than one SELECT query, split with a semicolon, like this:

	string SQL = "SELECT * FROM Customers; SELECT * FROM Orders;"
	
To differentiate between the two result sets, you need to apply a `reader.NextResult();`, like below:

	while (reader.Read())
	{
	    // (Process the category rows here.)
	}

	reader.NextResult();

	while (reader.Read())
	{
	    // (Process the product rows here.)
	}
	
_Note: Most of these code examples are from Chapter/Section 5.2._

### Conclusion

This has hopefully provided you a basic introduction to using the System.Data.SQLite and ADO.NET. Once you understand how ADO.NET works, System.Data.SQLite drops straight in. It follows all of the usual ADO.NET conventions.

