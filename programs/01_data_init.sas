**** INPUT SAMPLE DEMOGRAPHICS DATA;
/************************************************************************
* Program Name: 01_data_init.sas
* Purpose:      Initialize project environment and create mock ADSL data.
* Author:       Vilda_Duan
* Description:  Defines global options, custom formats, and creates the
* 'demog' dataset used across the Table 14.1 project.
************************************************************************/


data demog;
  label subjid = "Subject Number"
        trt    = "Treatment"
        gender = "Gender"
        race   = "Race"
        age    = "Age";
  input subjid trt gender race age @@;
datalines;
101 0 1 3 37   301 0 1 1 70   501 0 1 2 33   601 0 1 1 50   701 1 1 1 60
102 1 2 1 65   302 0 1 2 55   502 1 2 1 44   602 0 2 2 30   702 0 1 1 28
103 1 1 2 32   303 1 1 1 65   503 1 1 1 64   603 1 2 1 33   703 1 1 2 44
104 0 2 1 23   304 0 1 1 45   504 0 1 3 56   604 0 1 1 65   704 0 2 1 66
105 1 1 3 44   305 1 1 1 36   505 1 1 2 73   605 1 2 1 57   705 1 1 2 46
106 0 2 1 49   306 0 1 2 46   506 0 1 1 46   606 0 1 2 56   706 1 1 1 75
201 1 1 3 35   401 1 2 1 44   507 1 1 2 44   607 1 1 1 67   707 1 1 1 46
202 0 2 1 50   402 0 2 2 77   508 0 2 1 53   608 0 2 2 46   708 0 2 1 55
203 1 1 2 49   403 1 1 1 45   509 0 1 1 45   609 1 2 1 72   709 0 2 2 57
204 0 2 1 60   404 1 1 1 59   510 0 1 3 65   610 0 1 1 29   710 0 1 1 63
205 1 1 3 39   405 0 2 1 49   511 1 2 2 43   611 1 2 1 65   711 1 1 2 61
206 1 2 1 67   406 1 1 2 33   512 1 1 1 39   612 1 1 2 46   712 0 . 1 49
;
run;


**** DEFINE VARIABLE FORMATS NEEDED FOR TABLE;
proc format;
  value trt
    1 = "Active"
    0 = "Placebo";
  value gender
    1 = "Male"
    2 = "Female";
  value race
    1 = "White"
    2 = "Black"
    3 = "Other*";
run;