ods noproctitle;
ods excel file="c:\SASForDummies\Cars.xlsx" style=valight
 options(
   sheet_interval='none'
   sheet_name="Origin FREQ"
   autofilter='ON'
   title="CARS data"
   );
 proc freq data=sashelp.cars;
  table origin;
 run;

 ods graphics / width=400 height=200 imagefmt=png;
 proc sgplot data=sashelp.cars;
  vbar origin / stat=FREQ;
 run;
ods excel close;