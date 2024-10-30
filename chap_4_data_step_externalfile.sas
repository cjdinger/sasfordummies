%let path=c:\projects\sasfordummies;
data work.students;
  length student_name $ 14
    student_id $ 7
    birthday 8
    major $ 16
    current_age 8;
  informat birthday anydtdte20.;
  format birthday date9.;
  infile "&path/classdata.dat" dsd;
  input student_name
    student_id
    birthday 
    major;

  /* this math calculates current age */
  current_age =
    round(yrdif(birthday,date(),'AGE'),1);
;
run;