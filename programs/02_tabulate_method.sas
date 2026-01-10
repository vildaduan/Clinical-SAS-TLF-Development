/************************************************************************
* Program Name: 02_tabulate_method.sas
* Author:       Vilda_Duan
* Purpose:      Generate Table 14.1 using PROC TABULATE.
************************************************************************/

**** DEFINE OPTIONS FOR ASCII TEXT OUTPUT;
options nodate ls = 80 ps = 38 formchar = "|----|+|---+=|-/\<>*";


**** CREATE SUMMARY OF DEMOGRAPHICS WITH PROC TABULATE;
proc tabulate data=demog missing;
  class trt gender race;
  var age;

  table 
    (age='Age'*(n='n'*f=8. mean='Mean'*f=5.1 std='Standard Deviation'*f=5.1 min='Min'*f=3. max='Max'*f=3.)
     gender='Gender'*(n='n'*f=3. colpctn='%'*f=4.1)
     race='Race'*(n='n'*f=3. colpctn='%'*f=4.1)),
    (trt all='Overall');

  format trt trt. race race. gender gender.;

/*   title1 'Table 5.1'; */
  title2 'Demographics and Baseline Characteristics';
  footnote1 "* Other includes Asian, Native American, and other races.";
/*   footnote2 "Created by %sysfunc(getoption(sysin)) on &sysdate9.."; */
run;





