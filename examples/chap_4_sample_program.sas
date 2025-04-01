/* Is there a difference in weight gain      */
/* with these drinks? Buzz cola or Duff beer */
data drinks;
   length beverage $ 10;
   input beverage $ weight_gain @@;
   datalines;
buzz  4.5   buzz  6.2
buzz  9.6   buzz 12.8
buzz 12.0   buzz  9.9
buzz  2.8   buzz  5.0
buzz 10.9   buzz 11.5
buzz  3.9   buzz  9.6
buzz  8.7   buzz 10.0
buzz  7.6   buzz  8.0
duff  3.4   duff  1.2
duff  2.6   duff  4.9
duff  8.8   duff  0.6
duff  8.5   duff  2.0
duff  7.5   duff  5.4
duff  5.2   duff  6.9
duff  3.4   duff  9.5
duff  5.3   duff  2.1
;

ods graphics on;
title "Significant difference: Buzz & Duff?";
proc ttest data=drinks ;
   class beverage;
   var weight_gain;
run;
 