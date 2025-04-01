options nodate nonumber;

title;
ods escapechar='~';
ods text="~S={font_size=14pt font_weight=bold}~Analysis of Heart";
ods layout  start columns=2;
ods region;

title;
proc means data=sashelp.heart;
  class sex Smoking_Status;
  var Cholesterol Diastolic Systolic;
run;

ods region;
ods graphics / imagefmt=svg width=400 height=400;
title "Cholesterol by Smoking";
proc sgplot data=sashelp.heart ;
 hbox Cholesterol / group=Smoking_Status;
run;

ods layout end;
