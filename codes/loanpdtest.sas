libname lavdat 'E:\WORK\DATASET';
data loan;
set lavdat.loan_credit_clean;
if loanstatus in ('Current','FinalPaymentInProgress','Past Due (1-15 days)','Past Due (16-30 days)','Past Due (31-60 days)','Past Due (61-90 days)')
then do;C=1; D=0; T=intck('month',loanoriginationdate_num,20061);end;
if loanstatus in ('Completed')
then do;C=0; D=0; T=intck('month',loanoriginationdate_num,closeddate_num);end;
if loanstatus in ('Defaulted','Chargedoff','Cancelled')
then do;C=0; D=1; T=intck('month',loanoriginationdate_num,closeddate_num);end;
if loanstatus in ('Past Due (91-120 days)','Past Due (>120 days)')
then do;C=0; D=1; T=intck('month',loanoriginationdate_num,20061);end;
monthlypay=(LoanOriginalAmount_num*(1+BorrowerRate_num/12)**36)/(((1+BorrowerRate_num/12)**36-1)/(BorrowerRate_num/12));
delta=monthlypay-monthlyloanpayment_num;
EAD=monthlypay*term_num-lp_customerpayments_num;
RT=intck('month',closeddate_num,20061);
run; 

data loantry;
set loan;
drop listingkey creditgrade ProsperRating__Alpha_ groupkey 
loankey loanoriginationquarter memberkey listingnumber_num 
listingcreationdate_clean listingcreationdate_num closeddate_clean
prosperscore_num datecreditpulled_clean firstrecordedcreditline_clean
TotalProsperLoans_num TotalProsperPaymentsBilled_num OnTimeProsperPayments_num
ProsperPayments_LT_OneMonth_num ProsperPayments1Mon_PlusLate_num 
ProsperPrincipalBorrowed_num ProsperPrincipalOutstanding_num 
ScorexChangeAtTimeOfListing_num loanoriginationdate_clean closeddate_num
loanoriginationdate_num;
if RT<12 then CRT=0;
else CRT=1;
run;

/*
proc freq data=loantry;
tables C*D;
run;
*/

%let inputsnum= 
AmountDelinquent_num
AvailableBankcardCredit_num
BankcardUtilization_num
BorrowerAPR_num
BorrowerRate_num
CreditScoreRangeLower_num
CreditScoreRangeUpper_num
CurrentCreditLines_num
CurrentDelinquencies_num
DateCreditPulled_num
DebtToIncomeRatio_num
DelinquenciesLast7Years_num
EAD
EmploymentStatusDuration_num
EstimatedEffectiveYield_num
EstimatedLoss_num
EstimatedReturn_num
FirstRecordedCreditLine_num
InquiriesLast6Months_num
InvestmentFromFriendsAmount_num
InvestmentFromFriendsCount_num
Investors_num
LP_CollectionFees_num
LP_CustomerPayments_num
LP_CustomerPrincipalPayments_num
LP_GrossPrincipalLoss_num
LP_InterestandFees_num
LP_NetPrincipalLoss_num
LP_NonPrincipalRecoverypay_num
LP_ServiceFees_num
LenderYield_num
ListingCategory__numeric
LoanCurrentDaysDelinquent_num
LoanFirstDefaultedCycleNum_num
LoanMonthsSinceOrigination_num
LoanNumber_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
OpenCreditLines_num
OpenRevolvingAccounts_num
OpenRevolvingMonthlyPayment_num
PercentFunded_num
ProsperRating__numeric
PublicRecordsLast10Years_num
PublicRecordsLast12Months_num
Recommendations_num
RevolvingCreditBalance_num
StatedMonthlyIncome_num
T
Term_num
TotalCreditLinespast7years_num
TotalInquiries_num
TotalTrades_num
TradesNeverDelinquentpercent_num
TradesOpenedLast6Months_num;
%let inputschar=
CurrentlyInGroup
EmploymentStatus
IncomeRange
IncomeVerifiable
IsBorrowerHomeowner
;

data pdori;
set loantry;
drop C;
run;

proc sql noprint;
create table countd as
select D,
count(D) as count 
from pdori 
group by D;
select count into :n0-:n1 from countd;
select count(*) into :n from pdori;
quit;

data eq0;
set pdori;
if D=0; 
run;
data eq1;
set pdori;
if D=1; 
run;

proc surveyselect
data=eq1
out=resamp1
method = urs
n=&n0 outhits noprint;
run;
proc surveyselect
data=eq0
out=resamp
method = srs
n=&n1 noprint;
run;

/*data forweightlog;
set resamp1 eq0;
if D=0 then w=0.5/(&n0/&n);
else w=0.5/(&n1/&n);
run;

proc logistic data=forweightlog desc;
class &inputschar;
weight w;
model D= &inputsnum &inputschar/selection=backward fast slstay=0.1;
run;

data forpriorlog;
set resamp eq1;
   off=log(((&n1/&n)*0.5)/(&n0/&n*0.5));
run;
proc logistic data=forpriorlog desc;
model D= &inputsnum &inputschar/selection=backward fast slstay=0.1 offset=off;
run;
*/

data forpriorlog;
set resamp eq1;
   off=log(((&n0/&n)*0.5)/(&n1/&n*0.5));
run;
proc logistic data=forpriorlog desc;
class &inputschar;
model D= &inputsnum &inputschar/selection=stepwise offset=off;
run;

data forweightlog;
set resamp eq1;
if D=0 then w=0.5/(&n1/&n);
else w=0.5/(&n0/&n);
run;

proc logistic data=forweightlog;
class &inputschar;
weight w;
model D= &inputsnum &inputschar/selection=backward fast slstay=0.1;;
run;

proc logistic data=pdori desc;
class &inputschar;
model D= &inputsnum &inputschar/selection=stepwise;
run;
proc datasets lib=work kill;run;
