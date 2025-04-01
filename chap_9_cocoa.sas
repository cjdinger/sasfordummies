data cocoa(keep=Cocoa_Concentration Gender);
 length Cocoa_Concentration $ 100
        Gender $ 1;
  do i = 1 to 147;
      Gender = 'F';
      prob = rand('normal',1,100);
      if prob < 44 then Cocoa_Concentration = "Dark Chocolate";
      else if prob < 84 then Cocoa_Concentration = "Milk Chocolate";
      else  Cocoa_Concentration = "White Chocolate";
      output;
  end;
    do i = 1 to 53;
      Gender = 'M';
      prob = rand('normal',1,100);
      if prob < 25 then Cocoa_Concentration = "Dark Chocolate";
      else if prob < 53 then Cocoa_Concentration = "Milk Chocolate";
      else  Cocoa_Concentration = "White Chocolate";
      output;
  end;
run;
proc sort data=cocoa; by Cocoa_Concentration; run;

proc freq data=cocoa;
 table Cocoa_Concentration * Gender / 		NOROW
		NOPERCENT
		NOCUM
		CHISQ
		SCORES=TABLE
		ALPHA=0.05;
run;