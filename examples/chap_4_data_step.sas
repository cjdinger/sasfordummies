data work.students;
  length student_name $ 14
    student_id $ 7
    birthday 8
    major $ 16
    current_age 8;
  informat birthday anydtdte20.;
  format birthday date9.;
  infile datalines dsd;
  input student_name
    student_id
    birthday 
    major;

  /* this math calculates current age */
  current_age =
    round(yrdif(birthday,date(),'AGE'),1);
  datalines;
Maggie Dylan,41968,27jan2005,SAS
Evelyn Lincoln,51970,08Aug2005,Design
Ann Gailey,61969,09mar2005,Spanish
Chris Dinger,71969,09aug2006,Computer Science
Jennie Tutone,8675309,02may2007,Fashion
;
run;