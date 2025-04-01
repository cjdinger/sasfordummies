/* Bring Candy data into modern era */
libname candy "C:\Program Files\SASHome\SASEnterpriseGuide\8\Sample\Data";

data candy_sales_summary;
 set candy.candy_sales_summary;
 date = intnx('year',date,20,'SAME');
 fiscal_year = put(year(date),$4.);
 fiscal_quarter = put(date,YYQZ6.);
run;