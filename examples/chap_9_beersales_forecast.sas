libname sample "C:\Program Files\SASHome\SASEnterpriseGuide\8\Sample\Data";

data beer_sales_monthly;
set sample.beer_sales;
 BeerSales = sales + (ifn(HighTemp>0,HighTemp,5) * (month*.2))*1000;
 format BeerSales comma12.;
 month = intnx('month','01Jan2019'd,month);
 format month monyy7.;
run;

ods graphics on;
PROC esm 
	DATA = WORK.beer_sales_monthly OUT=esm_fcst plot=all lead=24;
	ID Month interval=month accumulate=total;
  format BeerSales comma12.;
	forecast BeerSales / model=seasonal;
run;
