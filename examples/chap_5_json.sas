filename data "C:\SASForDummies\Examples\nested-data.json";
libname people json fileref=data;

proc sql;
 create table combined as
 select t1.name, t1.age,
   t2.color, t2.movie
 from people.root t1 inner join
  people.favorites t2
  on (t1.ordinal_root = t2.ordinal_root);
quit;
