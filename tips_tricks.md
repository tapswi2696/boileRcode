#### Tips and tricks 

#1. Get list of package contains 

Example 01: Get list of all function in Purrr

`ls("package:purrr")`

Example 02: Get list of function matches with grep

`grep("impute_", ls("package:recipes"), value = TRUE)`

#2. Convert data frame to JSON by Rows

`toJSON(x = mtcars2, dataframe = 'rows', pretty = T)`



