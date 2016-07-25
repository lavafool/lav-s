libname w "E:\lav's\DATASET";
%let regnums=
ProsperRating__numeric
ListingCategory__numeric
EmploymentStatusDuration_num
CreditScoreRangeLower_num
CreditScoreRangeUpper_num
CurrentCreditLines_num
TotalCreditLinespast7years_num
OpenRevolvingAccounts_num
OpenRevolvingMonthlyPayment_num
InquiriesLast6Months_num
TotalInquiries_num
CurrentDelinquencies_num
AmountDelinquent_num
DelinquenciesLast7Years_num
PublicRecordsLast10Years_num
PublicRecordsLast12Months_num
RevolvingCreditBalance_num
BankcardUtilization_num
AvailableBankcardCredit_num
TotalTrades_num
TradesNeverDelinquentpercent_num
TradesOpenedLast6Months_num
DebtToIncomeRatio_num
StatedMonthlyIncome_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
Recommendations_num
InvestmentFromFriendsCount_num
InvestmentFromFriendsAmount_num
Investors_num
CreditHistory;
%let regchars=
clu_ES
IsBorrowerHomeowner
CurrentlyInGroup
IR
IncomeVerifiable;

/**rrmodels*/
proc means data=w.Loan_credit_rr_train_try noprint nway;
class EmploymentStatus;
var rr;
output out=level mean=rr;
run;


proc cluster data=level method=ward outtree=fortree noprint;
freq _freq_;
var rr;
id EmploymentStatus;
run;

proc means data=w.Loan_credit_rr_train_try noprint nway;
class incomerange;
var rr;
output out=level mean=rr;
run;


proc cluster data=level method=ward outtree=fortree noprint;
freq _freq_;
var rr;
id incomerange;
run;


data w.rr_clu2;
set w.Loan_credit_rr_train_try;
if EmploymentStatus in ('Not available','Self-employed','Retired') then clu_ES='NA&SE&R';
else if EmploymentStatus in ('Employed','Full-time') then clu_ES='FT&E';
else clu_ES='other';
if incomerange in('$50,000-74,999','$75,000-99,999','$1-24,999','Not employed') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3'; 
run;

data rr_model;
set w.rr_clu2;
YY=log(RR/(1-RR));
YY2=-log(-log(RR));
run;

ods output ParameterEstimates=ParaEst1;
proc glmselect data=rr_model namelen=50;
     class &regchars/split;  
     model YY= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m1;
run;
ods output ParameterEstimates=ParaEst2;
proc glmselect data=rr_model namelen=50;
     class &regchars/split;  
     model YY2= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m2;
run;

/*ods listing close;
ods results off;*/
ods output ParameterEstimates=ParaEst; 
proc univariate data=rr_model; 
var RR;   
histogram RR / beta   ctext  = blue; 
run;
/*ods results on;
ods listing;*/

proc rank data=rr_model out=rr_rank;
    var RR;
	ranks r_RR;
run;

proc sql noprint;
select estimate into :para1-:para6 from ParaEst;
select count(*) into :nb1 from rr_rank;
quit;

data rr_model2;
set rr_rank;
pb=probbeta(RR,&para3,&para4);
YY3=probit(pb);
YY4=probit(r_RR/(&nb1+1));
run;
ods output ParameterEstimates=ParaEst3;
proc glmselect data=rr_model2 namelen=50;
     class &regchars/split;  
     model YY3= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m3;
run;
ods output ParameterEstimates=ParaEst4;
proc glmselect data=rr_model2 namelen=50;
     class &regchars/split;  
     model YY4= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m4;
run;

proc sql noprint;
select count(*) into :dima from ParaEst1;
select count(*) into :dimb from ParaEst2;
select count(*) into :dimc from ParaEst3;
select count(*) into :dimd from ParaEst4;
quit;
proc sql noprint;
select estimate into :esta1-:esta%left(&dima.) from ParaEst1;
select estimate into :estb1-:estb%left(&dimb.) from ParaEst2;
select estimate into :estc1-:estc%left(&dimc.) from ParaEst3;
select estimate into :estd1-:estd%left(&dimd.) from ParaEst4;
quit;
proc sql noprint;
select effect into :tv1 separated by ' ' from ParaEst1;
select effect into :tv2 separated by ' ' from ParaEst2;
select effect into :tv3 separated by ' ' from ParaEst3;
select effect into :tv4 separated by ' ' from ParaEst4;
quit;

data rr_test;
set w.loan_credit_rr_hold_try;
Intercept=1;
if incomerange in('$50,000-74,999','$75,000-99,999','$1-24,999','Not employed') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3';
CurrentlyInGroup_False=(CurrentlyInGroup='False'); 
IR_1=(IR='1');
IR_2=(IR='2');
run;

%macro tests();
data test1;
set rr_test;
array c1{&dima.} coe1-coe%left(&dima.);
array py{&dima.} py1-py%left(&dima.);
array var1{*} &&tv1;
%do i=1 %to &dima.;
c1{&i}=&&esta&i;
py{&i}=c1{&i}*var1{&i};
%end;
pyy1=sum(py1-py%left(&dima.));
prr1=exp(pyy1)/(1+exp(pyy1));
rsq1=(prr1-RR)**2;
keep pyy1 prr1 rsq1;
run;

data test2;
set rr_test;
array c2{&dimb.} coe1-coe%left(&dimb.);
array py{&dimb.} py1-py%left(&dimb.);
array var2{*} &&tv2;
%do i=1 %to &dimb.;
c2{&i}=&&estb&i;
py{&i}=c2{&i}*var2{&i};
%end;
pyy2=sum(py1-py%left(&dimb.));
prr2=exp(-exp(-pyy2));
rsq2=(prr2-RR)**2;
keep pyy2 prr2 rsq2;
run;

data test3;
set rr_test;
array c3{&dimc.} coe1-coe%left(&dimc.);
array py{&dimc.} py1-py%left(&dimc.);
array var3{*} &&tv3;
%do i=1 %to &dimc.;
c3{&i}=&&estc&i;
py{&i}=c3{&i}*var3{&i};
%end;
pyy3=sum(py1-py%left(&dimc.));
prr3=betainv(probnorm(pyy3),&&para3,&&para4);
rsq3=(prr3-RR)**2;
keep pyy3 prr3 rsq3;
run;

data test4;
set rr_test;
array c4{&dimd.} coe1-coe%left(&dimd.);
array py{&dimd.} py1-py%left(&dimd.);
array var4{*} &&tv4;
%do i=1 %to &dimd.;
c4{&i}=&&estd&i;
py{&i}=c4{&i}*var4{&i};
%end;
pyy4=sum(py1-py%left(&dimd.));
prr4=probnorm(pyy4);
rsq4=(prr4-RR)**2;
keep pyy4 prr4 rsq4;
run;
%mend tests;
%tests;

proc sql noprint;
select sqrt(mean(rsq1)) into :r1 from test1;
select sqrt(mean(rsq2)) into :r2 from test2;
select sqrt(mean(rsq3)) into :r3 from test3;
select sqrt(mean(rsq4)) into :r4 from test4;
quit;
%put &r1 &r2 &r3 &r4;

/* proc datasets library=work kill;quit; */

/* GOGOGO BetaQuantile!! */
data rr_quantbeta;
set rr_model2;
if incomerange in('$50,000-74,999','$75,000-99,999','$1-24,999','Not employed') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3';
CurrentlyInGroup_False=(CurrentlyInGroup='False'); 
IR_1=(IR='1');
IR_2=(IR='2');
keep &tv3 YY3;
run;
%put &tv3;
%let quantvars=
IR_1 IR_2 ProsperRating__numeric ListingCategory__numeric OpenRevolvingMonthlyPayment_num
InquiriesLast6Months_num CurrentDelinquencies_num RevolvingCreditBalance_num TotalTrades_num
TradesNeverDelinquentpercent_num LoanOriginalAmount_num MonthlyLoanPayment_num InvestmentFromFriendsCount_num
InvestmentFromFriendsAmount_num
;

ods graphics on;
proc quantreg ci=none data=rr_quantbeta outest=quantest;
model YY3 = &quantvars /
quantile= 0.1 to 0.9 by 0.1
plot=quantplot
;
run;

proc transpose data=quantest out=quant_pre0;
	var &tv3;
run;
data quant_pre0;
set quant_pre0;
drop _label_;
run;

proc iml;
use rr_test ;
read all var{&tv3} into varmat; 
use quant_pre0;
read all var{_name_} into varname;
read all into coestmat;
coestmat=coestmat[,2:10];
Q0=j(dimension(varmat)[1],9,.);
Q0=varmat*coestmat;
Q0=betainv(probnorm(Q0),&&para3,&&para4);
predq=j(dimension(varmat)[1],1,.);
predq=(Q0[,+]-0.5#(Q0[,1]-1))/10;
create Q from predq;
append from predq;
quit;

data testq;
merge rr_test Q;
rsqq=(COL1-RR)**2;
run;

proc sql noprint;
select sqrt(mean(rsqq)) into :rq from testq;
quit;
%put &r3 &r4 &rq;

/* norm quant with all vars and selection 
data rr_quant0;
set rr_model2;
run;

ods graphics on;
proc quantreg ci=resampling data=rr_quant0 outest=quantest00 namelen=50;
class &regchars;
model YY3 = &regnums &regchars /
quantile= 0.1 to 0.9 by 0.1
plot=quantplot
;
run;

%let quantselvars=
ProsperRating__numeric
ListingCategory__numeric
OpenRevolvingAccounts_num
OpenRevolvingMonthlyPayment_num
TotalInquiries_num
DelinquenciesLast7Years_num
PublicRecordsLast12Months_num
AvailableBankcardCredit_num
TotalTrades_num
TradesNeverDelinquentpercent_num
StatedMonthlyIncome_num
LoanOriginalAmount_num
InvestmentFromFriendsCount_num
CurrentlyInGroup_False
IR_1
IR_2;

data rr_quant_sele;
set rr_quant0;
if incomerange in('$50,000-74,999','$75,000-99,999','$1-24,999','Not employed') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3';
CurrentlyInGroup_False=(CurrentlyInGroup='False'); 
IR_1=(IR='1');
IR_2=(IR='2');
keep &quantselvars RR YY3;
run;

proc quantreg ci=none data=rr_quant_sele outest=quantest_sele ;
model YY3 = &quantselvars /
quantile= 0.05 to 0.95 by 0.05;
run;

proc transpose data=quantest_sele out=quant_pre_sele0;
	var &quantselvars;
run;

data rr_test_sele;
set rr_test;
run;

proc iml;
use rr_test_sele ;
read all var{&quantselvars} into varmat; 
use quant_pre_sele0;
read all var{_name_} into varname;
read all into coestmat;
coestmat=coestmat[,2:20];
Q0=j(dimension(varmat)[1],19,.);
Q0=varmat*coestmat;
Q0=betainv(probnorm(Q0),&&para3,&&para4);
predq=j(dimension(varmat)[1],1,.);
predq=(Q0[,+]-0.5#(Q0[,1]+Q0[,19]))/20/0.9;
create Qs from predq;
append from predq;
quit;

data testqs;
merge rr_test Qs;
rsqqs=(COL1-RR)**2;
run;

proc sql noprint;
select sqrt(mean(rsqqs)) into :rqs from testqs;
quit;
%put &r3 &r4 &rq &rqs;*/

