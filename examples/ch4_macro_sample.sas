%macro runMeans(whichData);
  title "Output of MEANS for &whichData";

  proc means data=&whichData 
    mean stddev n mode;
  run;

%mend;

%runMeans(sashelp.class);
%runMeans(sashelp.cars);