proc import 
 file="C:\Users\sascrh\OneDrive - SAS\Projects\SfD\SfD_Ed3_files\Examples\transactions.csv"
 out=work.transactions
 dbms=csv
 replace;
run;

data work.transactions;
 length FullName $ 25
        ID $ 10
        DollarsSpent 8
        ZipCode $ 5
        BigSpender 8;
 infile "C:\Users\sascrh\OneDrive - SAS\Projects\SfD\SfD_Ed3_files\Examples\transactions.csv" 
   dsd firstobs=2;
 input FullName ID DollarsSpent ZipCode;
 format DollarsSpent dollar8.2;
 BigSpender = (DollarsSpent >= 250);
run;
