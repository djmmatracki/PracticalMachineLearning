
EXEC [NYCTaxi].[PredictTipSingleModeSciKitPy]
    @model = 'Logistic Regression Revoscalepy',
    @passenger_count = 1,
    @trip_distance = 2.5,
    @trip_time_in_secs = 630,
    @pickup_latitude = 40.763958,
    @pickup_longitude = -73.973373,
    @dropoff_latitude = 40.782139,
    @dropoff_longitude = -73.977303