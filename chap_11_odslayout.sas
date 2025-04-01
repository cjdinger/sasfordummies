options nodate nonumber;
ods pdf file="c:\Projects\Dummies\MyReport.pdf" style=journal 
 notoc ;
title "My Class Report";
proc means data=sashelp.class;
  class sex;
  var weight height;
run;
ods pdf startpage=no;
ods graphics / width=400 height=400;
proc sgplot data=sashelp.class;
 histogram weight;
run;
ods pdf close;


ods html5 file="C:\Projects\Dummies\Layout.html" 
  (Title="My Report")
 style=htmlencore ;

title;
ods escapechar='~';
ods text="~S={font_size=14pt font_weight=bold}~My gridded report";
ods layout  start columns=2;
ods region;

title;
proc means data=sashelp.class;
  class sex;
  var weight height;
run;

ods region;
ods graphics / imagefmt=svg width=400 height=400;
title "Weight distribution";
proc sgplot data=sashelp.class;
 histogram weight;
run;

ods layout end;
ods html5 close;