ods _all_ close;

ods graphics / reset=all;
libname candy "C:\Program Files\SASHome\SASEnterpriseGuide\8\Sample\Data";
ods html5 path="c:\Temp\chap8"
  style=plateau image_dpi=300 gtitle;

ods graphics / width=800 height=600 imagename='8-01' imagefmt=png ;

title "Sales by Region for Fiscal Year 2003";
proc sgplot data=candy.candy_sales_summary;
  where Fiscal_Year='2003';
  format Sale_Amount dollar12.;
  vbar region / response=sale_amount datalabel;
  yaxis label="Sale Amount";
run;

ods graphics / width=800 height=600 imagename='8-02' imagefmt=png ;

title "Sales by Region for Fiscal Year 2003, Grouped by quarter";

proc sgplot data=candy.candy_sales_summary;
  where Fiscal_Year='2003';
  format Sale_Amount dollar12.;
  vbar region / response=sale_amount datalabel
    group=Fiscal_Quarter groupdisplay=cluster;
  yaxis label="Sale Amount";
run;

data ate;
 length status $ 10 pct 8;
 status = "eaten";  pct = 10; output;
 status = "not eaten"; pct=90; output;
run;

ods graphics / width=800 height=600 imagename='8-03' imagefmt=png ;
title height=3 "How much pie did I eat?";
proc sgpie data=ate;
  styleattrs  datacolors=(white lightorange);
  pie status / response=pct 
  datalabelattrs=(Size = 22pt) 
  datalabeldisplay=(category);
run;

title height=3 "How much [donut] did I eat?";
ods graphics / width=800 height=600 imagename='8-03-donut' imagefmt=png ;
proc sgpie data=ate;
  styleattrs  datacolors=(white lightorange);
  donut status / response=pct 
  datalabelattrs=(Size = 22pt) 
  datalabeldisplay=(category);
run;

proc sql;
   create table work.summarizedsales as 
   select t1.region, 
          intnx('month',t1.date,0,'e') as month 
            format=monyy7.,
          /* gross_sales */
            (sum(t1.sale_amount)) format=dollar10. as gross_sales
      from candy.candy_sales_summary t1
      group by t1.region,
               month;
quit;


ods graphics / width=800 height=600 imagename='8-04' imagefmt=png ;
title "Gross Sales by Region";
proc sgplot data=summarizedsales;
 styleattrs datasymbols=(circlefilled squarefilled starfilled);
 vline Month / response=Gross_Sales markers
   group=Region lineattrs=(thickness=2);
 yaxis label="Sales in dollars";
 xaxis type=time display=(nolabel);
run;

title "Gross Sales by Region (smoothed)";
ods graphics / width=800 height=600 imagename='8-04-smoothed' imagefmt=png ;
proc sgplot data=summarizedsales;
 styleattrs datasymbols=(circlefilled squarefilled starfilled);
 vline Month / response=Gross_Sales markers
   group=Region lineattrs=(thickness=2 );
 yaxis label="Sales in dollars";
 xaxis type=time display=(nolabel);
run;

title "Gross Sales by Region (log scale)";
ods graphics / width=800 height=600 imagename='8-05' imagefmt=png ;
proc sgplot data=summarizedsales;
 styleattrs datasymbols=(circlefilled squarefilled starfilled);
 vline Month / response=Gross_Sales markers
   group=Region lineattrs=(thickness=2 );
 yaxis label="Sales in dollars"  
   type=log logbase=10 logstyle=logexpand;
 xaxis type=time display=(nolabel);
run;

data cust_discount;
 set candy.candy_sales_summary;
 keep Sale_Amount discount_pct units;
 where Customer=4;
 discount_pct = input(discount,percent4.);
run;
title "Correlation Sale Amount vs Discount Given (Customer=4)";
ods graphics / width=800 height=600 imagename='8-06' imagefmt=png ;
proc sgplot data=cust_discount;
  format discount_pct percent4.;   
  reg x=discount_pct y=Sale_Amount /
     markerattrs=(size=.8) lineattrs=(color=red);
  yaxis label="Sale (dollars)";
  xaxis label="Discount" ;
run;

proc sql;
   create table work.bubblesum as 
   select /* total_units */
            (sum(t1.units)) as total_units, 
          /* average_sale */
            (avg(t1.sale_amount)) format=dollar10. as average_sale, 
          t1.subcategory
      from candy.candy_sales_summary t1
      where t1.Fiscal_Year = '2003'
      group by t1.subcategory;
quit;

title "Average Sale by Units Sold for each Subcategory (year=2003)";
ods graphics / width=800 height=600 imagename='8-07' imagefmt=png ;
proc sgplot data=bubblesum;
 bubble x=subcategory y=total_units size=average_sale / 
   datalabel=average_sale datalabelpos=top datalabelattrs=(size=10);
 format total_units comma12.;
 yaxis min=0 label="Units sold";
run; 


proc sql;
   create table work.hm as 
   select t1.fiscal_month_num, 
          t1.fiscal_year, 
          /* sum_of_sale_amount */
            (sum(t1.sale_amount)) format=dollar9.2 as sales
      from candy.candy_sales_summary t1
      where t1.fiscal_year ^= "2004"
      group by t1.fiscal_year,
               t1.fiscal_month_num;
quit;

ods graphics / width=800 height=600 imagename='8-08' imagefmt=png ;
title "Heatmap of Sales by Month each Year";
proc sgplot data=hm;
 heatmapparm y=Fiscal_Year x=Fiscal_Month_Num colorresponse=Sales ;
 xaxis minor values=(1 to 12 by 1) label="Month";
 yaxis label="Year";
run;


ods graphics / width=800 height=600 imagename='8-09' imagefmt=png ;
title "Box Plot of Sales by Subcategory";
proc sgplot data=candy.candy_sales_summary;
 vbox sale_amount / category=subcategory ;
 yaxis label="Sale Amount";
run;



/*--Adverse Events timeline data--*/
data ae0;
   retain aestdateMin;
   retain aeendateMax;
   attrib aestdate informat=yymmdd10. format=date7.;
   attrib aeendate informat=yymmdd10. format=date7.;
   format aestdateMin aeendateMax date7.;
   drop aestdateMin aeendateMax;
   input aeseq aedecod $ 5-39 aesev $ aestdate aeendate;

   aestdateMin=min(aestdate, aestdateMin);
   aeendateMax=max(aeendate, aeendateMax);
   call symputx('mindate', aestdateMin);
   call symputx('maxdate', aeendateMax);
   y=aeseq;
   if aedecod=" " then y=-9;

   cards;
.                                       MILD      2023-03-06  2023-03-06  Legend
.                                       MODERATE  2023-03-06  2023-03-06  Legend
.                                       SEVERE    2023-03-06  2023-03-06  Legend
1   DIZZINESS                           MODERATE  2023-03-06  2023-03-07          
2   COUGH                               MILD      2023-03-20  .                   
3   DERMATITIS                          MILD      2023-03-26  2023-06-18          
4   DIZZINESS                           MILD      2023-03-27  2023-03-27          
5   EKG T WAVE INVERSION                MILD      2023-03-30  .                   
6   DIZZINESS                           MILD      2023-04-01  2023-04-11          
7   DIZZINESS                           MILD      2023-04-01  2023-04-11          
8   DERMATITIS                          MODERATE  2023-03-26  2023-06-18          
9   HEADACHE                            MILD      2023-05-17  2023-05-18          
10  DERMATITIS                          MODERATE  2023-03-26  2023-06-18          
11  PRURITUS                            MODERATE  2023-05-27  2023-06-18          
;
run;
/*proc print;run;*/

/*--Evaluate min and max day and dates--*/
data _null_;
  set ae0;
  minday=0;
  maxday= &maxdate - &mindate;
  minday10 = -10;
  mindate10=&mindate - 10;
  call symputx('minday', minday);
  call symputx('maxday', maxday);
  call symputx('minday10', minday10);
  call symputx('mindate10', mindate10);
  run;

/*--Compute start and end date and bar caps based on event start, end--*/
data ae2;
  set ae0;

  aestdy= aestdate-&mindate+0;
  aeendy= aeendate-&mindate+0;
  stday=aestdy;
  enday=aeendy;

  if aestdy=. then do;
    stday=&minday;
	lcap='ARROW';
  end;
  if aeendy=. then do;
    enday=&maxday;
    hcap='ARROW';
  end;

  xs=0;
  run;

/*ods escapechar="^";*/

/*--Custom style for severity of events--*/
proc template;
   define Style AETimelineV93; 
     parent = styles.htmlblue;
      style GraphColors from graphcolors /
           "gdata1" = cx5fcf5f
           "gdata2" = cxdfcf3f
           "gdata3" = cxbf3f3f;
      style GraphFonts from GraphFonts /                                   
         'GraphDataFont' = ("<sans-serif>, <MTsans-serif>",7pt)  
         'GraphValueFont' = ("<sans-serif>, <MTsans-serif>",9pt) 
         'GraphTitleFont' = ("<sans-serif>, <MTsans-serif>",11pt);  
   end;
run;

/*--Draw the Graph--*/
ods html5 style=AETimelineV93 image_dpi=300 gtitle;
ods graphics / reset width=800 height=600 imagename='8-11' imagefmt=png ;
title "Adverse Events for Patient Id = 04-048-25211";
proc sgplot data=ae2 noautolegend nocycleattrs;
  /*--Draw the events--*/
  highlow y=aeseq low=stday high=enday / group=aesev lowlabel=aedecod type=bar 
          barwidth=0.8 lineattrs=(color=black) lowcap=lcap highcap=hcap name='sev';

  /*--Assign dummy plot to create independent X2 axis--*/
  scatter x=aestdate y=aeseq /  markerattrs=(size=0) x2axis;

  refline 0 / axis=x lineattrs=(thickness=1 color=black);

  /*--Assign axis properties data extents and offsets--*/
  yaxis display=(nolabel noticks novalues) type=discrete;
  xaxis grid label='Study Days' offsetmin=0.02 offsetmax=0.02 
        values=(&minday10 to &maxday by 2);
  x2axis notimesplit display=(nolabel) offsetmin=0.02 offsetmax=0.02 
        values=(&mindate10 to &maxdate);

  /*--Draw the legend--*/
  keylegend 'sev'/ title='Severity :';
  run;



data sankey;
  input id x y thickness y2 y3 xl xh llabel $46-48 hlabel $50-52;
  datalines;
1  0.1  0.8    1   .      .    .     .                
1  0.15 0.8    1   .      .    .     .                
1  0.2  0.76   1   .      .    .     .                
1  0.3  0.44   1   .      .    .     .                
1  0.4  0.4    1   .      .    .     .                
1  0.5  0.4    1   .      .    .     .                
1  0.5  0.4    1   .      .    .     .                
1  0.7  0.4    1   .      .    .     .                

2  0.1  0.2    5   .      .    .     .                
2  0.18 0.2    5   .      .    .     .                
2  0.25 0.25   5   .      .    .     .                
2  0.3  0.50   5   .      .    .     .                
2  0.4  0.53   5   .      .    .     .                
2  0.5  0.53   5   .      .    .     .                
2  0.7  0.53   5   .      .    .     .                

3  0.1  0.55   1   .      .    .     .                
3  0.15 0.55   1   .      .    .     .                
3  0.2  0.56   1   .      .    .     .                
3  0.3  0.64   1   .      .    .     .                
3  0.4  0.66   1   .      .    .     .                
3  0.5  0.66   1   .      .    .     .                
3  0.9  0.66   1   .      .    .     .               

1   .   .      .   0.8    .    0.1   0.12         3
1   .   .      .   0.4    .    0.35  0.37    3    
1   .   .      .   0.4    .    0.38  0.40         3
1   .   .      .   0.4    .    0.62  0.64    3    
1   .   .      .   0.4    .    0.65  0.67         3

2   .   .      .   .    0.2    0.1   0.12         18
2   .   .      .   .    0.535  0.35  0.37    18   
2   .   .      .   .    0.535  0.38  0.40         18
2   .   .      .   .    0.535  0.62  0.64    18   
2   .   .      .   .    0.535  0.65  0.67         18

3   .   .      .   0.55   .    0.1   0.12         3
3   .   .      .   0.66   .    0.35  0.37    3    
3   .   .      .   0.66   .    0.38  0.40         3
3   .   .      .   0.66   .    0.62  0.64    3    
3   .   .      .   0.66   .    0.65  0.67         3
3   .   .      .   0.66   .    0.88  0.90    3    
;
run;

/*--Break up links by group for different thickness--*/
data sankey2;
  length label $10;
  retain del 0.02;
  set sankey end=last;
  if id=2 then do;
    id2=id; id=.;
  end;
  output;

  /*--Add additional items--*/
  if last then do;
    /*--Labels--*/
    xlbl=0.1; ylbl=0.8+del; label='Organic'; output;
        xlbl=0.1; ylbl=0.55+del; label='Offer 1'; output;
        xlbl=0.35; ylbl=0.66+del; label='Offer 2'; output;
        xlbl=0.62; ylbl=0.66+del; label='Offer 3'; output;
        xlbl=0.85; ylbl=0.66+del; label='Conversion'; output;
        xlbl=0.1 ; ylbl=0.2+0.11; label='Search'; output;

        /*--Annoation--*/
        xa=0.05; ya=0.83; anno='1'; output;
        xa=0.77; ya=0.77;  anno='2'; output;
        xa=0.77; ya=0.5;  anno='3'; output;

        /*--Lines--*/
        lid=1; xln=0.085; yln=0.75; output;
        lid=1; xln=0.08;  yln=0.75; output;
        lid=1; xln=0.08;  yln=0.83; output;
        lid=1; xln=0.075; yln=0.83; output;
        lid=1; xln=0.08;  yln=0.83; output;
        lid=1; xln=0.08;  yln=0.90; output;
        lid=1; xln=0.085; yln=0.90; output;

        lid=2; xln=0.71; yln=0.71; output;
        lid=2; xln=0.71; yln=0.72; output;
        lid=2; xln=0.77; yln=0.72; output;
        lid=2; xln=0.77; yln=0.73; output;
        lid=2; xln=0.77; yln=0.72; output;
        lid=2; xln=0.82; yln=0.72; output;
        lid=2; xln=0.82; yln=0.71; output;

        lid=3; xln=0.7; yln=0.5;   output;
        lid=3; xln=0.75;  yln=0.5; output;
  end;
run;



/*--Render the Diagram--*/
ods graphics /  attrpriority=color width=800 height=600 imagename='8-12' imagefmt=png ;

title height=3 "Flow of imaginary web site";
proc sgplot data=sankey2 noborder noautolegend nocycleattrs;
  styleattrs datacontrastcolors=(darkred  blue cx5f9f1f)
             datacolors=(darkred  blue cx5f9f1f);
  series x=x y=y / group=id lineattrs=(pattern=solid thickness=12) 
         nomissinggroup transparency=0.8 smoothconnect;
  series x=x y=y / group=id2 lineattrs=(pattern=solid  thickness=62 color=cx5f9f1f) 
         nomissinggroup transparency=0.8 smoothconnect;
  highlow y=y2 low=xl high=xh / highlabel=hlabel lowlabel=llabel type=bar 
          intervalbarwidth=10 group=id transparency=0.3 nooutline 
          labelattrs=(color=black size=10 weight=bold);
  highlow y=y3 low=xl high=xh / highlabel=hlabel lowlabel=llabel type=bar 
          intervalbarwidth=62 group=id2 transparency=0.3 nooutline
          fillattrs=(color=cx5f9f1f) labelattrs=(color=black size=10 weight=bold);
  scatter x=xlbl y=ylbl / datalabel=label datalabelpos=topright markerattrs=(size=0) 
          datalabelattrs=(size=12 weight=bold);
  series x=xln y=yln / group=lid nomissinggroup lineattrs=(color=black);
  scatter x=xa y=ya / datalabel=anno datalabelpos=center 
          markerattrs=(symbol=circlefilled color=lightblue size=18) 
          datalabelattrs=(size=12 weight=bold);
  xaxis min=0 max=1 offsetmin=0 offsetmax=0 display=none;
  yaxis min=0 max=1 offsetmin=0 offsetmax=0 display=none;
run;

ods html5 close;