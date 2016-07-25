libname w "E:\lav's\DATASET";
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

data w.Loan_credit_rr_train_try w.Loan_credit_rr_hold_try;
set w.Loan_credit_rr_Nmiss;
p=ranuni(1);
if  p<0.75 then output w.Loan_credit_rr_train_try;
else output w.Loan_credit_rr_hold_try;
run;
