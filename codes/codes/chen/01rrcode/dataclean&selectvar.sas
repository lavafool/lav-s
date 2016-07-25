libname W "E:\lav's\DATASET";
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


proc logistic data=w.loan_default_train namelen=50;
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
/*CurrentlyInGroup*/
/*IR*/
/*ListingCategory__numeric*/
/*OpenRevolvingMonthlyPayment_num*/
/*TotalInquiries_num*/
/*AmountDelinquent_num*/
/*RevolvingCreditBalance_num*/
/*BankcardUtilization_num*/
/*TradesNeverDelinquentpercent_num*/
/*DebtToIncomeRatio_num*/
/*LoanOriginalAmount_num*/
/*MonthlyLoanPayment_num*/
/*InvestmentFromFriendsCount_num*/
/*Investors_num*/
/*CreditHistory*/

data w.loan_default_train;
set w.loan_default_train;
if CurrentlyInGroup='False' then CurrentlyInGroup_Find=1;
else  CurrentlyInGroup_Find=0;
if IR='1' then IR_1ind=1 ;else IR_1ind=0;
if IR='2' then IR_2ind=1;else IR_2ind=0;
run;


data w.loan_default_hold;
set w.loan_default_hold;
if CurrentlyInGroup='False' then CurrentlyInGroup_Find=1;
else  CurrentlyInGroup_Find=0;
if IR='1' then IR_1ind=1 ;else IR_1ind=0;
if IR='2' then IR_2ind=1;else IR_2ind=0;
run;

PROC EXPORT data=w.Loan_default_train
outfile="E:\lav's\DATASET\Loan_default_train.csv"
dbms=csv
replace;
run;
PROC EXPORT data=w.Loan_default_hold
outfile="E:\lav's\DATASET\Loan_default_hold.csv"
dbms=csv
replace;
run;
