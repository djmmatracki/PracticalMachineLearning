
## How to execute external scripts in SQL Server Machine Learning Services?

The first step is to enable external scripts using the code below.

```
EXEC SP_CONFIGURE 'external scripts enabled', 1
GO
RECONFIGURE
GO
```

### How to use sp_execute_external_script?

Below there is a template of the process.

```
sp_execute_external_script
    @labguage = N'language',
    @script = N'script'
    [ , @input_data_1 = N'input_data_1' ]
    [ , @input_data_1_name = N'input_data_1_name' ]
    [ , @input_data_1_order_by_columns = 
        N'input_data_1_order_by_columns' ]
    [ , @input_data_1_partition_by_columns = 
        N'input_data_1_partition_by_columns' ]
    [ , @output_data_1_name = N'output_data_1_name' ]
    [ , @parallel = 0 | 1 ]
    [ , @params = N'@parameter_name data_type [OUT | OUTPUT ] [ ,...n ]' ]
    [ , @parameter1 = 'value1' [ OUT | OUTPUT ] [ ,...n] ]
```

**@language** - indicates what language are we using 'R' or 'Python' or 'Java'
**@scripts** - Our script in text format.
**@input_data_1** - It allows us to create a querry in T-SQL that will be passed to our script.
**@input_data_1_name** - It allows us to change the default querry result name from ```InputDataSet```.
**@input_data_1_order_by_columns** - It allows us to indicate the column that the data from our querry will be sorted by.
**@input_data_1_partition_by_columns** - It allows us to indicate the column that the data will be partitioned by.
**@parallel** - It allows us to force multi-threaded running of the python/R script
**@params** - it allows to pass a list of params to the Python/R script

Names of result columns can be set by ```WITH RESULT SETS```.


Example code:

```
EXEC sp_execute_external_script @language =N'Python',
    @script=N'OutputDataSet = InputDataSet',
    @input_data_1 = N'SELECT 1 AS CheckToSeeIfPythonIsWorking'
WITH RESULT SETS ((CheckToSeeIfPythonIsWorking int not null));
GO
```

## Configuration

Executing external scripts is managed by SQL Server Extensibility Framework. The resources used by our scripts can be limited. The initial configuration is limiting the resources not used by SQL Server to 20%.

To change the initial configuration, which is recommended, execute the code below.

```
EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'max server memory (MB)', 20000
RECONFIGURE

ALTER EXTERNAL RESOURCE POOL "default"
WITH (max_memory_percent = 40);

ALTER RESOURCE GOVERNER RECONFIGURE
GO
SELECT *
FROM sys.resource_governer_external_resource_pools
WHERE name = 'default';

```
