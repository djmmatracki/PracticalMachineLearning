USE ML;
GO

CREATE OR ALTER PROCEDURE [NYCTaxi].[SerializePlots]
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @query nvarchar(max) = 
	N'SELECT cast(tipped as int) as tipped, tip_amount, fare_amount FROM [NYCTaxi].[Trips]'
	EXECUTE sp_execute_external_script
	@language = N'Python',
	@script = N'
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pickle

fig_handle = plt.figure()
plt.hist(InputDataSet.tipped)
plt.xlabel("Tipped")
plt.ylabel("Counts")
plt.title("Histogram, Tipped")
plot0 = pandas.DataFrame(data=[pickle.dumps(fig_handle)], columns=["plot"])
plt.clf()

plt.hist(InputDataSet.tip_amount)
plt.xlabel("Tip amount $")
plt.ylabel("Counts")
plt.title("Histogram, Tip amount")
plot1 = pandas.DataFrame(data=[pickle.dumps(fig_handle)], columns=["plot"])
plt.clf()

plt.hist(InputDataSet.fare_amount)
plt.xlabel("Fare amount $")
plt.ylabel("Counts")
plt.title("Histogram, Fare amount")
plot2 = pandas.DataFrame(data=[pickle.dumps(fig_handle)], columns=["plot"])
plt.clf()

plt.scatter(InputDataSet.fare_amount, InputDataSet.tip_amount)
plt.xlabel("Fare Amount $")
plt.ylabel("Tip Amount $")
plt.title("Tip amount")

plot3 = pandas.DataFrame(data=[pickle.dumps(fig_handle)], columns=["plot"])
plt.clf()

OutputDataSet = plot0.append(plot1, ignore_index=True).append(plot2, ignore_index=True).append(plot3, ignore_index=True)

', @input_data_1 = @query
WITH RESULT SETS ((plot varbinary(max)))
END

EXEC NYCTaxi.SerializePlots;