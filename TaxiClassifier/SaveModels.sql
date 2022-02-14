-- DECLARE @model varbinary(max);
-- EXEC [NYCTaxi].[TrainTipPredictionModelRxPy] @model OUTPUT;
-- INSERT INTO [NYCTaxi].[Models]
--     (name, model)
-- VALUES('Logistic Regression Revoscalepy', @model);
SELECT *
FROM [NYCTaxi].[Models]