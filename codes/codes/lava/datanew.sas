libname w "D:\sas\sasfiles\DATASET";
data lava_def;
set w.Loan_credit_default;
run;
data Lava_RR;
set lava_def;
where rr>=0;
run;

proc contents data=lava_def;run;
proc freq dadta=lava_def;
table ListingCreationDate_clean;run;

data w.Lava_RR;
set Lava_RR;
if RR> 1 then RR=0.9999999;
CreditHistory=intck('month',FirstRecordedCreditLine_num,ListingCreationDate_num);
p0=(rr=0);
run;

proc stdize data=w.lava_rr reponly method=median out=rr_nonummiss;
var _numeric_;
run;


data w.rr_nomiss;
set rr_nonummiss;
if employmentstatus=' ' then  employmentstatus='Full-time';run;

data lava_def;
set w.rr_nomiss;
run;

proc sort data=lava_def;
by loanoriginationdate_num;
run;
data w.loan_logit_train w.loan_logit_hold;
set lava_def;
if _n_<10291 then output w.loan_logit_train;
else output  w.loan_logit_hold;
run;


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

proc means data=w.loan_logit_train noprint nway;
class EmploymentStatus;
var rr;
output out=level mean=rr;
run;


proc cluster data=level method=ward outtree=fortree;
freq _freq_;
var rr;
id EmploymentStatus;
run;

proc means data=w.loan_logit_train noprint nway;
class IncomeRange;
var rr;
output out=level mean=rr;
run;


proc cluster data=level method=ward outtree=fortree;
freq _freq_;
var rr;
id IncomeRange;
run;

data w.rr_clu;
set w.loan_logit_train;
if EmploymentStatus in ('Not available','Self-employed','Retired','Employed') then clu_ES='NA&E&R';
else if EmploymentStatus in ('Not employed','Part-time') then clu_ES='PT&NE';
else clu_ES='other';
if incomerange in ('$75,000-99,999','Not employed', '$1-24,999','$50,000-74,999') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3'; 
run;


%let regchars=
clu_ES
IsBorrowerHomeowner
CurrentlyInGroup
IR
IncomeVerifiable;


proc logistic data=w.rr_clu namelen=50;
class &regchars;
model p0= &regnums &regchars/selection=stepwise slentry=0.1 slstay=0.05;
run;

%let logitvars=
ListingCategory__numeric
EmploymentStatusDuration_num
TotalCreditLinespast7years_num
CurrentDelinquencies_num
RevolvingCreditBalance_num
AvailableBankcardCredit_num
TradesNeverDelinquentpercent_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
CreditHistory
clu_ES
CurrentlyInGroup
IR
IncomeVerifiable
;

proc logistic data=w.rr_clu des plot(only)=roc(id=obs) outmodel=rrlogit;
class &regchars;
model  p0=&logitvars/expb  rsquare  lackfit  covb  clodds=wald  ctable;
output out=results p=predict l=lower u=upper xbeta=logit;
run;

data logithold;
set w.loan_logit_hold;
if EmploymentStatus in ('Not available','Self-employed','Retired','Employed') then clu_ES='NA&E&R';
else if EmploymentStatus in ('Not employed','Part-time') then clu_ES='PT&NE';
else clu_ES='other';
if incomerange in ('$75,000-99,999','Not employed', '$1-24,999','$50,000-74,999') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3'; 
run;

proc logistic inmodel=rrlogit;
score data=logithold out=scr;
run;

ods printer pdf file='C:\out_npar1way_logit.pdf';
ods graphics on;
proc npar1way edf wilcoxon data=scr plots=(wilcoxonboxplot medianplot edfplot);
class p0;
var P_1;
run;
ods graphics off;
ods printer pdf close;


proc print data=scr;run;


/**0<rr<1**/
data w.Loan_credit_rr;
set w.Loan_credit_rr;
CreditHistory=intck('year',FirstRecordedCreditLine_num,loanoriginationdate_num);
if EmploymentStatus=' ' then EmploymentStatus='Full-time';
drop ProsperScore_num;
/*delete ProsperScore_num because 100% miss*/
run;
proc stdize data=w.Loan_credit_rr reponly method=median out=w.Loan_credit_rr_Nmiss;
var _numeric_;
run;
proc univariate data=w.Loan_credit_rr_Nmiss;
var LoanOriginationDate_num;
output out=p pctlpts  =80 pctlpre=p80;
run;
data w.Loan_credit_rr_train w.Loan_credit_rr_hold;
set w.Loan_credit_rr_Nmiss;
if  LoanOriginationDate_num<=18658 then output w.Loan_credit_rr_train;
else output w.Loan_credit_rr_hold;
run;

/**rrmodels*/
proc means data=w.Loan_credit_rr_train noprint nway;
class EmploymentStatus;
var rr;
output out=level mean=rr;
run;


proc cluster data=level method=ward outtree=fortree;
freq _freq_;
var rr;
id EmploymentStatus;
run;

proc means data=w.Loan_credit_rr_train noprint nway;
class incomerange;
var rr;
output out=level mean=rr;
run;


proc cluster data=level method=ward outtree=fortree;
freq _freq_;
var rr;
id incomerange;
run;


data w.rr_clu2;
set w.Loan_credit_rr_train;
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


proc glmselect data=rr_model namelen=50;
     class &regchars/split;  
     model YY= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m1;
run;

proc glmselect data=rr_model namelen=50;
     class &regchars/split;  
     model YY2= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m2;
	 run;
 
proc univariate data=rr_model; 
var RR;   
histogram RR / beta   ctext  = blue; 
run;

proc rank data=rr_model out=rr_rank;
    var RR;
	ranks r_RR;
run;


data rr_model2;
set rr_rank;
pb=probbeta(RR,0.24,0.23);
YY3=probit(pb);
YY4=probit(r_RR/3080);
run;

proc glmselect data=rr_model2 namelen=50;
     class &regchars/split;  
     model YY3= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m3;
run;
proc glmselect data=rr_model2 namelen=50;
     class &regchars/split;  
     model YY4= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m4;
run;

data rr_test;
set w.loan_credit_rr_hold;
Int=1;
if incomerange in('$50,000-74,999','$75,000-99,999','$1-24,999','Not employed') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3';
CurrentlyInGroup_False=(CurrentlyInGroup='False'); 
IR_1=(IR='1');
IR_2=(IR='2');
run;

%let tv1=
CurrentlyInGroup_False
IR_1
IR_2
ListingCategory__numeric
OpenRevolvingMonthlyPayment_num
TotalInquiries_num
AmountDelinquent_num
AvailableBankcardCredit_num
TradesNeverDelinquentpercent_num
DebtToIncomeRatio_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
InvestmentFromFriendsCount_num
Investors_num
;

%let tv2=
CurrentlyInGroup_False
IR_1
IR_2
ListingCategory__numeric
TotalInquiries_num
AmountDelinquent_num
BankcardUtilization_num
TradesNeverDelinquentpercent_num
DebtToIncomeRatio_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
InvestmentFromFriendsCount_num
Investors_num
;
%let tv3=
CurrentlyInGroup_False
IR_1
IR_2
ListingCategory__numeric
OpenRevolvingMonthlyPayment_num
TotalInquiries_num
AmountDelinquent_num
RevolvingCreditBalance_num
BankcardUtilization_num
TradesNeverDelinquentpercent_num
DebtToIncomeRatio_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
InvestmentFromFriendsCount_num
Investors_num
CreditHistory
;
%let tv4=
IR_1
IR_2
ListingCategory__numeric
OpenRevolvingMonthlyPayment_num
InquiriesLast6Months_num
CurrentDelinquencies_num
AmountDelinquent_num
RevolvingCreditBalance_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
InvestmentFromFriendsCount_num
Investors_num
CreditHistory
;


data test1;
set rr_test;
array c{15} coe1-coe15(0.919494,
0.400113,
2.067717,
1.508385,
0.153332,
0.000539,
-0.02616,
-0.000052909,
-0.000017286,
-1.433915,
0.219195,
0.001652,
-0.04786,
-1.065515,
-0.006388);
array py{15} py1-py15;
array var1{*} Int &tv1;
do i=1 to dim(var1);
py{i}=c{i}*var1{i};
end;
pyy1=sum(py1-py15);
prr1=exp(pyy1)/(1+exp(pyy1));
rsq1=(prr1-RR)**2;
keep pyy1 &tv1 prr1 rsq1;
run;


data test2;
set rr_test;
array c2{14} coe1-coe14(2.402315,
0.298756,
1.267717,
0.83287,
0.11656,
-0.022525,
-0.000036018,
0.654901,
-1.361964,
0.222748,
0.001518,
-0.043168,
-0.938511,
-0.006449);
array py{14} py1-py14;
array var2{*} Int &tv2;
do i=1 to dim(var2);
py{i}=c2{i}*var2{i};
end;
pyy2=sum(py1-py14);
prr2=exp(-exp(-pyy2));
rsq2=(prr2-RR)**2;
keep pyy2 &tv2 prr2 rsq2;
run;
data test3;
set rr_test;
array c2{17} coe1-coe17(-0.130986,
0.062188,
0.34744,
0.258368,
0.026566,
0.000114,
-0.004503,
-0.000009255,
-0.000001629,
0.077324,
-0.198082,
0.030094,
0.00024,
-0.00702,
-0.159042,
-0.000893,
0.003589);
array py{17} py1-py17;
array var3{*} Int &tv3;
do i=1 to dim(var3);
py{i}=c2{i}*var3{i};
end;
pyy3=sum(py1-py17);
prr3=betainv(probnorm(pyy3),0.24,0.23);
rsq3=(prr3-RR)**2;
keep pyy3 &tv3 prr3 rsq3;
run;
data test4;
set rr_test;
array c2{14} coe1-coe14(-0.235552,
0.458945,
0.372662,
0.029062,
0.000163,
-0.01301,
-0.008188,
-0.000008721,
-0.000002483,
0.000152,
-0.004708,
-0.119746,
-0.00048,
0.005843);
array py{14} py1-py14;
array var4{*} Int &tv4;
do i=1 to dim(var4);
py{i}=c2{i}*var4{i};
end;
pyy4=sum(py1-py14);
prr4=probnorm(pyy4);
rsq4=(prr4-RR)**2;
keep pyy4 &tv4 prr4 rsq4;
run;

proc univariate data=test1;
var rsq1;run;
proc univariate data=test2;
var rsq2;run;
proc univariate data=test3;
var rsq3;run;
proc univariate data=test4;
var rsq4;run;
