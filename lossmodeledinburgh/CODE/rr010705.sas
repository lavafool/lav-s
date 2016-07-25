*libname W "E:\STUDY\codes\sas\sasfiles\DATASET";
libname w "E:\lav's\DATASET";

data w.Loan_credit_default_RRpositive;
set w.Loan_credit_default(where=(RR>=0));
if RR> 1 then RR=0.9999999;
CreditHistory_Byear=intck('month',FirstRecordedCreditLine_num,ListingCreationDate_num);
p0=(rr=0);
/*p0=1 if rr=0*/
run;
proc stdize data= w.Loan_credit_default_RRpositive reponly method=median out=w.Loan_credit_default_RRpositive;
var _numeric_;
run;
/*proc freq data=w.loan_credit_rr;*/
/*tables EmploymentStatus*/
/*IsBorrowerHomeowner*/
/*CurrentlyInGroup*/
/*IncomeRange*/
/*IncomeVerifiable;*/
/*run;*/

/*EMPLYMENTSTATUS have missing value then replace the missing ones with the mode-'Full-time' */
data w.Loan_credit_default_RRpositive;
set w.Loan_credit_default_RRpositive;
if employmentstatus=' ' then  employmentstatus='Full-time';run;

data lava_def;
set w.Loan_credit_default_RRpositive;
run;

proc sort data=lava_def;
by loanoriginationdate_num;
run;
data w.loan_default_train w.loan_default_hold;
set lava_def;
if _n_<10291 then output w.loan_default_train;
else output  w.loan_default_hold;
run;
/*
NOTE: The data set W.LOAN_DEFAULT_TRAIN has 10290 observations and 88 variables.
NOTE: The data set W.LOAN_DEFAULT_HOLD has 4410 observations and 88 variables.
*/

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
CreditHistory_Byear;

proc means data=w.loan_default_train noprint nway;
class EmploymentStatus;
var rr;
output out=level mean=rr;
run;


proc cluster data=level method=ward outtree=fortree;
freq _freq_;
var rr;
id EmploymentStatus;
run;


data w.loan_default_train;
set w.loan_default_train;
if EmploymentStatus in ('Not available','Self-employed','Retired','Employed') then clu_ES='NA&E&R';
else if EmploymentStatus in ('Not employed','Part-time') then clu_ES='PT&NE';
else clu_ES='other&FT';
if incomerange in ('$75,000-99,999','Not employed', '$1-24,999','$50,000-74,999') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3'; 
run;

%let regchars=
clu_ES
IsBorrowerHomeowner
CurrentlyInGroup
IncomeRange
IncomeVerifiable;


proc logistic data=w.loan_default_train namelen=50 desc;
class &regchars;
model p0= &regnums &regchars/selection=backward fast slstay=0.05;
run;

/*proc freq data=w.loan_default_train;*/
/*tables employmentstatus;run;*/

/*HANDLE THE HOLD DATASET ABOUT CLUSTER*/
data w.loan_default_HOLD;
set w.loan_default_HOLD;
if EmploymentStatus in ('Not available','Self-employed','Retired','Employed') then clu_ES='NA&E&R';
else if EmploymentStatus in ('Not employed','Part-time') then clu_ES='PT&NE';
else clu_ES='other&FT';
if incomerange in ('$75,000-99,999','Not employed', '$1-24,999','$50,000-74,999') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3'; 
run;

/*according to Lava's selection,turn the classified variable into Dummy variable*/
/*seleted variables are as below*/
/*
CurrentlyInGroup
IR
ListingCategory__numeric   
EmploymentStatusDuration_num   
TotalCreditLinespast7years_num   
CurrentDelinquencies_num   
RevolvingCreditBalance_num   
AvailableBankcardCredit_num 
TradesNeverDelinquentpercent_num   
LoanOriginalAmount_num  
MonthlyLoanPayment_num 
CreditHistory_Byear   
clu_ES
*/

data w.loan_default_train;
set w.loan_default_train;
if CurrentlyInGroup='False' then CurrentlyInGroup_Find=1;
else  CurrentlyInGroup_Find=0;
if clu_ES='NA&E&R' then clu_ES_1ind=1;else clu_ES_1ind=0;
if clu_ES='PT&NE' then clu_ES_2ind=2;else clu_ES_2ind=0;
if IR='1' then IR_1ind=1 ;else IR_1ind=0;
if IR='2' then IR_2ind=1;else IR_2ind=0;
run;


data w.loan_default_hold;
set w.loan_default_hold;
if CurrentlyInGroup='False' then CurrentlyInGroup_Find=1;
else  CurrentlyInGroup_Find=0;
if clu_ES='NA&E&R' then clu_ES_1ind=1;else clu_ES_1ind=0;
if clu_ES='PT&NE' then clu_ES_2ind=2;else clu_ES_2ind=0;
if IR='1' then IR_1ind=1 ;else IR_1ind=0;
if IR='2' then IR_2ind=1;else IR_2ind=0;
run;

PROC EXPORT data=w.Loan_default_train
/*outfile="E:\STUDY\codes\sas\sasfiles\DATASET\Loan_default_train.csv"*/
outfile="E:\lav's\lossmodeledinburgh\Loan_default_train.csv"
dbms=csv
replace;
run;
PROC EXPORT data=w.Loan_default_hold
/*outfile="E:\STUDY\codes\sas\sasfiles\DATASET\Loan_default_hold.csv"*/
outfile="E:\lav's\lossmodeledinburgh\Loan_default_hold.csv"
dbms=csv
replace;
run;

%let regvars=
ListingCategory__numeric   
EmploymentStatusDuration_num   
TotalCreditLinespast7years_num   
CurrentDelinquencies_num   
RevolvingCreditBalance_num   
AvailableBankcardCredit_num 
TradesNeverDelinquentpercent_num   
LoanOriginalAmount_num  
MonthlyLoanPayment_num 
CreditHistory_Byear   
clu_ES_1ind
clu_ES_2ind
CurrentlyInGroup_Find
IR_1ind
IR_2ind;

*ods rtf file='E:\STUDY\codes\sas\lossmodeledinburgh\rr_result_01.doc';
ods rtf file="E:\lav's\lossmodeledinburgh\rr_result_01.doc";
proc logistic data=w.loan_default_train namelen=50 desc;
model p0= &regvars;
score data=w.loan_default_hold out=scoval outroc=rocval;
run;

/*输出评价指标KS*/
proc npar1way edf wilcoxon data=scoval;
   class p0;
   var p_1;
run;

/*计算quantile验证集预测值*/
DATA QUANTILE_PRE1;
SET w.loan_default_hold(
keep=
p0
loankey
&regvars
)
;
intercept=1;
run;

PROC IMPORT OUT=coe DATAFILE="E:\lav's\DATASET\para0705.csv" replace DBMS=csv ;
RUN;

ods listing close;
ods results off;
ods output Variables=get_name;
proc contents data=coe;run;
ods results on;
ods listing;
proc sql noprint;
	select variable into :vn separated by '" "' from get_name;
	select variable into :vars separated by ' ' from get_name;
quit;

proc iml;
	use quantile_pre1;
	read all var{&vars} into mata;
	read all var{p0} into p0;
	read all var{LoanKey} into loankey;
	use coe;
	read all var{&vars} into matb;
	q1=(mata#matb[1,])[,+];
	q2=(mata#matb[2,])[,+];
	q3=(mata#matb[3,])[,+];
	q4=(mata#matb[4,])[,+];
	q5=(mata#matb[5,])[,+];
	q6=(mata#matb[6,])[,+];
	q7=(mata#matb[7,])[,+];
	q8=(mata#matb[8,])[,+];
	q9=(mata#matb[9,])[,+];
	z=mata||p0||q1||q2||q3||q4||q5||q6||q7||q8||q9;
	z=char(z)||loankey;
	VNnew={%str("&vn" "p0" "q01" "q02" "q03" "q04" "q05" "q06" "q07" "q08" "q09" "loankey")};
	create quantile_pre0 from z[colname=VNnew];
	append from z;
quit;

DATA QUANTILE_PRE;
SET QUANTILE_PRE0;
DO M=loankey;	T=Q01;	R=1;	OUTPUT;	END;
DO M=loankey;	T=Q02;	R=2;	OUTPUT;	END;
DO M=loankey;	T=Q03;	R=3;	OUTPUT;	END;
DO M=loankey;	T=Q04;	R=4;	OUTPUT;	END;
DO M=loankey;	T=Q05;	R=5;	OUTPUT;	END;
DO M=loankey;	T=Q06;	R=6;	OUTPUT;	END;
DO M=loankey;	T=Q07;	R=7;	OUTPUT;	END;
DO M=loankey;	T=Q08;	R=8;	OUTPUT;	END;
DO M=loankey;	T=Q09;	R=9;	OUTPUT;	END;
RUN;
DATA QUANTILE_PRE;
SET QUANTILE_PRE;
Z=(T<0);
RUN;
PROC SORT DATA=QUANTILE_PRE;BY M R;RUN;
DATA QUANTILE_PRE;
SET QUANTILE_PRE;
BY M;
IF FIRST.M THEN K=0;
K+Z;
RUN;

PROC SQL;
CREATE TABLE QUANTILE_PRE_NEXT AS
SELECT
M,
p0,
max(K) as TAU
FROM  QUANTILE_PRE
GROUP BY 1,2
order by 1,2
;QUIT;
data QUANTILE_PRE_NEXT;
set QUANTILE_PRE_NEXT;
if tau=0  then  quantpred=1-(tau+1)*5/100;
else if tau=9 then quantpred=1-(tau*5+50)/100;
else quantpred=1-(2*tau*5+5)/100;
RUN;
proc univariate data=QUANTILE_PRE_NEXT; var quantpred; histogram quantpred; run;
proc freq data=QUANTILE_PRE_NEXT;tables quantpred;run;
proc export data=QUANTILE_PRE_NEXT
outfile="E:\lav's\DATASET\prdct_quantile_next.csv"
dbms=csv
replace;
run;

/*输出quantile评价指标KS*/
ods graphics on;
proc npar1way edf wilcoxon data=QUANTILE_PRE_NEXT plots=(wilcoxonboxplot medianplot edfplot);
class p0;
var quantpred;
run;
ods graphics off;

ods rtf close;
