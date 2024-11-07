ods powerpoint file="c:\SASForDummies\salesdeck.pptx"
  layout=twocontent
  nogtitle nogfootnote style=PowerPointLight;
title "Are gas guzzlers more expensive?";

proc odslist;
  item 'MPG: Worth the price?';
  item;
  p 'Other factors:';
  list / style=[bullet=check];
  item 'Leather seats';
  item 'AM Radio';
  item 'Seat belts';
run;

ods graphics / width=500 height=400;
proc sgplot data=sashelp.cars;
 scatter x=MPG_City y=MSRP;
run;

ods powerpoint close;