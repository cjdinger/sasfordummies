data ate;
 length status $ 10 pct 8;
 status = "eaten";  pct = 10; output;
 status = "not eaten"; pct=90; output;
run;

/* change the ODS HTML5 statement depending on where running */
ods html5(eghtml) gtitle ;
title height=3 "How much pie did I eat?";
proc sgpie data=ate;
  styleattrs  datacolors=(white lightorange);
  pie status / response=pct 
  datalabelattrs=(Size = 22pt) 
  datalabeldisplay=(category);
run;