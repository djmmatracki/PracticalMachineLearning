# Our goal

Our friend a taxi driver asked us a favour. He wants us to tell him when he will get a tip. We have the data about his every trip and tips that he received.

We will use matplotlib to plot the data.


First of all we declare the data that we need.
```SQL
CREATE OR ALTER PROCEDURE [NYCTaxi].[SerializerPlots]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @query nvarchar(max) =
    N'SELECT cast(tipped as int) as tipped, tip_amount, fare_amount FROM [NYCTaxi].[Trips]'
```

Then we import libraies that we need, including pickle which serializes plots. Working with SQL Server Machine Learning Services our every plot has to be saved in binary mode. That's why we have to delare it using the command below.

```python
import matplotlib
matplotlib.use("Agg")
```

This statement indicates that our backend is not interactive and the result is a object with a PNG file. Next statements create our plots and eventually save them in one file.

The next step is to read the saved plots using a python script.

To connect to our SQL Server we will use the module ```pyodbc```.

```python
import pyodbc
import pickle
import os

cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER={MS};DATABASE={ML};Trusted_Connection=yes;')
```

Then we execute the procedure NYCTaxi.SerializePlots, deserialize the plots and save them into a png file.

```python
cursor = cnxn.cursor()
cursor.execute("EXECUTE NYCTaxi.SerializePlots")
tables = cursor.fetchall()
```

