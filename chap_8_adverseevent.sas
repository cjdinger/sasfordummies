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
ods html5 path="c:\Temp\chap8"
  style=AETimelineV93 image_dpi=300 gtitle;
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

title;
footnote;