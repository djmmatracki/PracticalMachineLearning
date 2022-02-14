USE ML
GO

CREATE OR ALTER PROCEDURE [NYCTaxi].[TrainTipPredictionModelRxPy]
    (@trained_model varbinary(max) OUTPUT)
AS
BEGIN
    EXEC sp_execute_external_script
    @language = N'Python',
    @script = N'
import numpy
import pickle
from revoscalepy.functions.RxLogit import rx_logit
from revoscalepy import rx_serialize_model

X = InpuDataSet[["passenger_count", "trip_distance", "trip_time_in_secs", "direct_distance"]]
y = numpy.ravel(InputDataSet[["tipped"]])

logitObj = rx_logit("tiped ~ passenger_count + trip_distance + trip_time_in_secs + direct_distance", data=InputDataSet)
serialized_model = rx_serialize_model(logitObj)',
    @input_data_1 = N'select tipped, fare_amount, passenger_count, trip_time_in_secs, trip_distance, [NYCTaxi].fnCalculateDistance(pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude) as direct_distance from [NYCTaxi].[Training]',
    @input_data_name_1 = N'InputDataSet',
    @params = N'@trained_model varbinary(max) OUTPUT',
    @trained_model = @trained_model OUTPUT;
END;