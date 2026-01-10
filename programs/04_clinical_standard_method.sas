/************************************************************************
* Program Name: 04_clinical_standard_method.sas
* Author:       Vilda_Duan
* Purpose:      Industry Standard Table 14.1 with P-Values.
************************************************************************/

/*****************************************************************
* 1. DATA INITIALIZATION
******************************************************************/

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN;
**** CALCULATIONS SO NOW TRT HAS VALUES 0 = PLACEBO, 1 = ACTIVE,;
**** AND 2 = OVERALL.;
data demog;
    set demog;
    output;
    trt = 2;
    output;
run;

**** AGE STATISTICS PROGRAMMING *********************************;
**** GET P VALUE FROM NON PARAMETRIC COMPARISON OF AGE MEANS.;
proc npar1way
    data = demog
    wilcoxon
    noprint;
    where trt in (0,1);
    class trt;
    var age;
    output out = pvalue wilcoxon;
run;

proc sort
    data = demog;
    by trt;
run;

***** GET AGE DESCRIPTIVE STATISTICS N, MEAN, STD, MIN, AND MAX.;
proc univariate
    data = demog noprint;
    by trt;
    var age;
    output out = age
        n = _n mean = _mean std = _std min = _min
        max = _max;
run;

**** FORMAT AGE DESCRIPTIVE STATISTICS FOR THE TABLE.;
data age;
    set age;
    format n mean std min max $14.;
    drop _n _mean _std _min _max;
    
    n = put(_n, 3.);
    mean = put(_mean, 7.1);
    std = put(_std, 8.2);
    min = put(_min, 7.1);
    max = put(_max, 7.1);
run;

**** TRANSPOSE AGE DESCRIPTIVE STATISTICS INTO COLUMNS.;
proc transpose
    data = age
    out = age
    prefix = col;
    var n mean std min max;
    id trt;
run;

**** CREATE AGE FIRST ROW FOR THE TABLE.;
data label;
    set pvalue(keep = p2_wil rename = (p2_wil = pvalue));
    length label $ 85;
    label = "Age (years)";
run;

**** APPEND AGE DESCRIPTIVE STATISTICS TO AGE P VALUE ROW AND;
**** CREATE AGE DESCRIPTIVE STATISTIC ROW LABELS.;
data age;
    length label $ 85 col0 col1 col2 $ 25 ;
    set label age;
    
    keep label col0 col1 col2 pvalue ;
    if _n_ > 1 then 
        select;
            when(_NAME_ = 'n')     label = "    N";
            when(_NAME_ = 'mean')  label = "    Mean";
            when(_NAME_ = 'std')   label = "    Standard Deviation";
            when(_NAME_ = 'min')   label = "    Minimum";
            when(_NAME_ = 'max')   label = "    Maximum";
            otherwise;
        end;
run;
**** END OF AGE STATISTICS PROGRAMMING **************************;


/*****************************************************************
* 2. GENDER STATISTICS
******************************************************************/

**** GENDER STATISTICS PROGRAMMING ******************************;
**** GET SIMPLE FREQUENCY COUNTS FOR GENDER.;
proc freq
    data = demog
    noprint;
    where trt ne .;
    tables trt * gender / missing outpct out = gender;
run;

**** FORMAT GENDER N(%) AS DESIRED.;
data gender;
    set gender;
    where gender ne .;
    length value $25;
    value = put(count,4.) || ' (' || put(pct_row,5.1) || '%)';
run;

proc sort
    data = gender;
    by gender;
run;

**** TRANSPOSE THE GENDER SUMMARY STATISTICS.;
proc transpose
    data = gender
    out = gender(drop = _name_)
    prefix = col;
    by gender;
    var value;
    id trt;
run;

**** PERFORM CHI-SQUARE ON GENDER COMPARING ACTIVE VS PLACEBO.;
proc freq
    data = demog
    noprint;
    where gender ne . and trt not in (., 2);
    table gender * trt / chisq;
    output out = pvalue pchi;
run;

**** CREATE GENDER FIRST ROW FOR THE TABLE.;
data label;
    set pvalue(keep = p_pchi rename = (p_pchi = pvalue));
    length label $ 85;
    label = "Gender";
run;

**** APPEND GENDER DESCRIPTIVE STATISTICS TO GENDER P VALUE ROW;
**** AND CREATE GENDER DESCRIPTIVE STATISTIC ROW LABELS.;
data gender;
    length label $ 85 col0 col1 col2 $ 25 ;
    set label gender;
    
    keep label col0 col1 col2 pvalue ;
    if _n_ > 1 then
        label = "    " || put(gender, gender.);
run;
**** END OF GENDER STATISTICS PROGRAMMING ***********************;


/*****************************************************************
* 3. RACE STATISTICS
******************************************************************/

**** RACE STATISTICS PROGRAMMING ********************************;
**** GET SIMPLE FREQUENCY COUNTS FOR RACE;
proc freq
    data = demog
    noprint;
    where trt ne .;
    tables trt * race / missing outpct out = race;
run;

**** FORMAT RACE N(%) AS DESIRED;
data race;
    set race;
    where race ne .;
    length value $25;
    value = put(count,4.) || ' (' || put(pct_row,5.1) || '%)';
run;

proc sort
    data = race;
    by race;
run;

**** TRANSPOSE THE RACE SUMMARY STATISTICS;
proc transpose
    data = race
    out = race(drop = _name_)
    prefix=col;
    by race;
    var value;
    id trt;
run;


**** PERFORM FISHER'S EXACT ON RACE COMPARING ACTIVE VS PLACEBO.;
proc freq
    data = demog
    noprint;
    where race ne . and trt not in (.,2);
    table race * trt / exact;
    output out = pvalue exact;
run;

**** CREATE RACE FIRST ROW FOR THE TABLE.;
data label;
    set pvalue(keep = xp2_fish rename = (xp2_fish = pvalue));
    length label $ 85;
    label = "Race";
run;

**** APPEND RACE DESCRIPTIVE STATISTICS TO RACE P VALUE ROW AND;
**** CREATE RACE DESCRIPTIVE STATISTIC ROW LABELS.;
data race;
    length label $ 85 col0 col1 col2 $ 25 ;
    set label race;
    
    keep label col0 col1 col2 pvalue ;
    if _n_ > 1 then
        label= "    " || put(race, race.);
run;
**** END OF RACE STATISTICS PROGRAMMING *************************;


/*****************************************************************
* 4. TABLE GENERATION & REPORTING
******************************************************************/

**** CONCATENATE AGE, GENDER, AND RACE STATISTICS AND CREATE;
**** GROUPING GROUP VARIABLE FOR LINE SKIPPING IN PROC REPORT.;
data forreport;
    set age(in = in1)
        gender(in = in2)
        race(in = in3);
        
    group = sum(in1 * 1, in2 * 2, in3 * 3);
run;

**** DEFINE THREE MACRO VARIABLES &N0, &N1, AND &NT THAT ARE USED;
**** IN THE COLUMN HEADERS FOR "PLACEBO," "ACTIVE" AND "OVERALL";
**** THERAPY GROUPS.;
data _null_;
    set demog end = eof;
    /* IMG_7768 continues */
    **** CREATE COUNTER FOR N0 = PLACEBO, N1 = ACTIVE.;
    if trt = 0 then
        n0 + 1;
    else if trt = 1 then
        n1 + 1;
        
    **** CREATE OVERALL COUNTER NT.;
    nt + 1;
    
    **** CREATE MACRO VARIABLES &N0, &N1, AND &NT.;
    if eof then
        do;
            call symput("n0", compress('(N=' || put(n0, 4.) || ')'));
            call symput("n1", compress('(N=' || put(n1, 4.) || ')'));
            call symput("nt", compress('(N=' || put(nt, 4.) || ')'));
        end;
run;

**** USE PROC REPORT TO WRITE THE TABLE TO FILE.;
options nonumber nodate ls = 84 missing = " "
        formchar = "|----|+|---+=|-/\<>*";

proc report
    data = forreport
    nowindows
    spacing = 1
    headline
    headskip
    split = "|";
    
/*     columns ("--" group label col1 col0 col2 pvalue); */
    
    define group   / order order = internal noprint;
    define label   / display width=23 " ";
    define col0    / display center width = 14 "Placebo|&n0";
    define col1    / display center width = 14 "Active|&n1";
    define col2    / display center width = 14 "Overall|&nt";
    define pvalue  / display center width = 14 " |P-value**"
                     f = pvalue6.4;
                     
    break after group / skip;
    
/*     title1 "Company"; */
/*     title2 "Protocol Name"; */
/*     title3 "Table 5.3"; */
    title4 "Table 14.1 Summary of Demographic and Baseline Characteristics";
    
    footnote1 "----------------------------------------------------";
    footnote2 "* Other includes Asian, Native American, and other"
              " races.";
    footnote3 "** P-values: Age = Wilcoxon rank-sum, Gender "
              "= Pearson's chi-square, "
              "Race = Fisher's exact test.";
    footnote4 " ";
/*     footnote5 "Created by %sysfunc(getoption(sysin)) on " */
/*               "&sysdate9..."; */
run;