/* Putting it all together                   */
/* First, a macro variable that allows us to */
/* easily change the column we want to use   */
/* in just one place                         */
%let mpgVar = mpg_city; /* or mpg_highway */

/* Next, a PROC SQL step to calculate the    */
/* average value across MAKEs                */
proc sql noprint;
  create table work.example4 as
    select make,
      avg(&mpgVar) as avg_mpg format 4.2 
    from sashelp.cars
      where origin="USA"
        group by make
          order by avg_mpg desc;

  /* new instruction: count the "makes" and store */
  /* in a macro variable named "howMany"          */
  select count(distinct make) into :howMany
    from sashelp.cars
      where origin="USA";
quit;

/* Now, use the new data table and macro values */
/* in a report                                  */
/* This title and PRINT step create a tabular   */
/* view of the data                             */
title "Analyzed %sysfunc(trim(&howMany)) values of Make";

proc print data=work.example4
  label noobs;
  var make avg_mpg;
  label avg_mpg="Average &mpgVar";
run;

/* This SGPLOT step creates a vertical bar    */
/* chart of the data                          */
title; /* clear title */
ods graphics / width=600 height=400;

proc sgplot data=work.example4;
  vbar make / response=avg_mpg;
  xaxis label="Make";
  yaxis label="Average &mpgVar";
run;