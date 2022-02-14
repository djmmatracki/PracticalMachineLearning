## Detecting fraud by invoices.


### Benford Law

If a variable can take varius orders of magnitude, the probability of occurence of it's first digit k is

$$\log_{10}(1 + \frac{1}{k})$$


Nowadays Benford law is widely used to detect tax fraud.

### Problem

We are going to try to find out which company's that made a deal with our client issued a fraudulent invoice based on Benford Law.

### Input Data

We will need data on the frequency of the first digits in the amounts of invoices issued. Therefore data that is returned from ```BenfordFraud.VendorInvoiceDigits``` function. Using the code below we will get the frequency of first digit in invoices for each company.

```SQL
SELECT *
FROM [BenfordFraud.VendorInvoiceDigits] (default)
ORDER BY VendorNumber;
```

Having data on the frequency of occurrence of digits, we can check whether they are consistent with those of the Benford distribution. To accomplish this we will use the following code.

```SQL
USE ML;
GO

CREATE OR ALTER PROCEDURE [BenfordFraud].getPotentialFraudulentVendors (@threshold float = 0.05)
AS
BEGIN
	EXEC sp_execute_external_script
		@language = N'R',
		@script = N'
			library(reshape2);
			dd = dcast(InputDataSet, VendorNumber ~ Digits, value.var="Freq");

			OutputDataSet = cbind(dd, apply(dd[,-1], 1, function(xx) chisq.test(xx, p=(log(1+1/1:9))/log(10)))$p.value));
			
			colnames(OutputDataSet) <- c("VendorNumber", "Digit1", "Digit2", "Digit3", "Digit4", "Digit5", "Digit6", "Digit7", "Digit8", "Digit9", "Pvalue");
			
			OutputDataSet <-- subset(OutputDataSet, Pvalue < threshold);
			',
		@input_data_1 = N'
			SELECT *
			FROM [ML].[BenfordFraud].[VendorInvoiceDigits] (default)
			ORDER BY VendorNumber asc, Digits asc;',
		@params = N'threshold float',
		@threshold = @threshold
WITH RESULT SETS ((VendorNumber varchar(10), Digit1 int, Digit2 int, Digit3 int, Digit4 int, Digit5 int, Digit6 int, Digit7 int, Digit8 int, Digit9 int, Pvalue float));
END;

INSERT INTO [BenfordFraud].[FraudulentVendors]
EXEC [BenfordFraud].getPotentialFraudulentVendors 0.10;
```

We make our dataset wider. It changes our original dataset in a way that every row is a different company and the columns are the occurences of each digit.

```R
library(reshape2);
dd = dcast(InputDataSet, VendorNumber ~ Digits, value.var="Freq");

```

Now we add a new column that contains the result of chi-squared test.
```R
OutputDataSet = cbind(dd, apply(dd[,-1], 1, function(xx) chisq.test(xx, p=(log(1+1/1:9))/log(10)))$p.value));
```

Then we name our columns and remove those rows that don't match our threshold.
```R
colnames(OutputDataSet) <- c("VendorNumber", "Digit1", "Digit2", "Digit3", "Digit4", "Digit5", "Digit6", "Digit7", "Digit8", "Digit9", "Pvalue");

OutputDataSet <-- subset(OutputDataSet, Pvalue < threshold);
```