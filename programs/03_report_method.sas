/************************************************************************
* Program Name: 03_report_method.sas
* Author:       Vilda_Duan
* Purpose:      Generate Table 14.1 using PROC REPORT Compute Blocks.
************************************************************************/

**** DEFINE OPTIONS FOR ASCII TEXT OUTPUT;
options nodate nocenter ls = 70
        formchar = "|----|+|---+=|-/\<>*";

**** CREATE SUMMARY OF DEMOGRAPHICS WITH PROC TABULATE;
proc report
    data = demog
    nowindows
    missing
    headline;

    column ('--' trt,
            ( ("-- Age --"
                age = agen age = agemean age = agestd age = agemin
                age = agemax)
              gender, (gender = gendern genderpct)
              race, (race = racen racepct)));

    define trt /across format = trt. " ";
    define agen /analysis n format = 3. 'N';
    define agemean /analysis mean format = 5.3 'Mean';
    define agestd /analysis std format = 5.3 'SD';
    define agemin /analysis min format = 3. 'Min';
    define agemax /analysis max format = 3. 'Max';

    define gender /across "-- Gender --" format = gender.;
    define gendern /analysis n format = 3. 'N';
    define genderpct /computed format = percent5. '(%)';
    define race /across "-- Race --" format = race.;
    define racen /analysis n format = 3. width = 6 'N';
    define racepct /computed format = percent5. '(%)';

    compute before;
        totga = sum(_c6_, _c8_, _c10_);
        totgp = sum(_c23_, _c25_, _c27_);
        totra = sum(_c12_, _c14_, _c16_);
        totrp = sum(_c29_, _c31_, _c33_);
    endcomp;

    compute genderpct;
        _c7_ = _c6_ / totga;
        _c9_ = _c8_ / totga;
        _c11_ = _c10_ / totga;
        _c24_ = _c23_ / totgp;
        _c26_ = _c25_ / totgp;
        _c28_ = _c27_ / totgp;
    endcomp;

    compute racepct;
        _c13_ = _c12_ / totra;
        _c15_ = _c14_ / totra;
        _c17_ = _c16_ / totra;
        _c30_ = _c29_ / totrp;
        _c32_ = _c31_ / totrp;
        _c34_ = _c33_ / totrp;
    endcomp;

/*     title1 'Table 5.2'; */
    title2 'Demographics and Baseline Characteristics';
/*     footnote1 "Created by %sysfunc(getoption(sysin))" */
/*               " on &sysdate9.."; */
run;