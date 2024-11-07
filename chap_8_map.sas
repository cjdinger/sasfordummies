/* Adapted from an example by Robert Allison  */
/* https://blogs.sas.com/content/graphicallyspeaking/how-to-make-your-data-look-worse-than-it-really-is/ */
/* Download data directly from Census site */
filename src "%sysfunc(getoption(WORK))/sashie.zip";

proc http 
  method="GET"
  url="https://www2.census.gov/programs-surveys/sahie/datasets/time-series/estimates-acs/sahie-2022-csv.zip"
  out=src;
run;

/* Read the CSV from the ZIP file */
filename srczip ZIP "%sysfunc(getoption(WORK))/sashie.zip" member="sahie_2022.csv";
filename csv temp;

data _null_;
  rc=fcopy('srczip','csv');
run;

data sashie (keep = statefips countyfips state_name county_name pctui);
  infile csv firstobs=86 dlm=',' dsd;
  length state_name $70 length county_name $45;
  input year version statefips countyfips geocat agecat racecat sexcat iprcat
    NIPR nipr_moe 
    NUI nui_moe 
    NIC nic_moe 
    PCTUI pctui_moe 
    PCTIC pctic_moe 
    PCTELIG pctelig_moe 
    PCTLIIC pctliic_moe
    state_name county_name
  ;

  if geocat=50 and /* county level, not state */
  year=2022 and
    version=. and
    agecat=0 and 
    racecat=0 and 
    sexcat=0 and
    iprcat=0
    then output;
run;

data sashie;
  set sashie;
  label pctui='Uninsured';
  label county_name='County';
  format pctui percentn7.1;
  pctui=pctui/100;
  length id $8;
  id='US-'||trim(left(put(statefips,z2.)))||trim(left(put(countyfips,z3.)));
  county_name=trim(left(county_name))||', '||trim(left(fipstate(statefips)));
run;

data my_map;
  set maps.uscounty;
  if state=46 and county=113 then
    county=102;
  length id $8;
  id='US-'||trim(left(put(state,z2.)))||trim(left(put(county,z3.)));
run;

/* create state borders, with internal county borders removed */
proc gremove data=my_map out=state_outlines;
  by state;
  id county;
run;

/* 
Repeat the first obsn of a polygon as the last, so the series plot will 'close' the polygon.
Also insert 'missing' values at the end of each segment, so series line won't be connected
between polygons.
*/
data state_outlines;
  set state_outlines;
  retain x_first y_first;
  by state segment notsorted;
  output;

  if first.state or first.segment or x=. then
    do;
      x_first=x;
      y_first=y;
    end;

  if last.state or last.segment or x=. then
    do;
      x=x_first;
      y=y_first;
      output;
      x=.;
      y=.;
      output;
    end;
run;

ods _all_ close;
ods graphics / reset=all;
ods html5 path="c:\Temp\chap8"
  style=plateau image_dpi=300 gtitle;
ods graphics / width=800 height=600 imagename='8-10' imagefmt=png;
title height=2 "Uninsured percent of population under 65 years (2022)";
title2 height=1.5 "Source: US Census Bureau, Small Area Health Insurance Estimates";

proc sgmap mapdata=my_map maprespdata=sashie plotdata=state_outlines;
  label pctui='Uninsured';
  label county_name='County';
  choromap pctui / mapid=id id=id
    colormodel=(cxf9ece1 cxfbc088 cxfc9036 cxe1540b cxa43800)
    lineattrs=(thickness=1 color=gray88)
    name='map';
  series x=x y=y / lineattrs=(color=gray55);  /* overlay state outlines */
  gradlegend 'map' / position=right;
run;

ods html5 close;