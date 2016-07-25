libname lavdat 'E:\WORK\DATASET';
data loan;
set lavdat.loan_credit_clean;
if loanstatus in ('Current','FinalPaymentInProgress','Past Due (1-15 days)','Past Due (16-30 days)','Past Due (31-60 days)','Past Due (61-90 days)')
then do;C=1; M=0; T=intck('month',loanoriginationdate_num,20061);end;
if loanstatus in ('Completed')
then do;C=1; M=2; T=intck('month',loanoriginationdate_num,closeddate_num);end;
if loanstatus in ('Defaulted','Chargedoff','Cancelled')
then do;C=0; M=1; T=intck('month',loanoriginationdate_num,closeddate_num);end;
if loanstatus in ('Past Due (91-120 days)','Past Due (>120 days)')
then do;C=0; M=1; T=intck('month',loanoriginationdate_num,20061);end;
monthlypay=(LoanOriginalAmount_num*(1+BorrowerRate_num/12)**36)/(((1+BorrowerRate_num/12)**36-1)/(BorrowerRate_num/12));
delta=monthlypay-monthlyloanpayment_num;
EAD=monthlypay*term_num-lp_customerpayments_num;
R0=LP_NonPrincipalRecoverypay_num+LP_GrossPrincipalLoss_num-LP_NetPrincipalLoss_num+LP_ServiceFees_num+LP_CollectionFees_num;
RR=(LP_NonPrincipalRecoverypay_num+LP_GrossPrincipalLoss_num-LP_NetPrincipalLoss_num+LP_ServiceFees_num+LP_CollectionFees_num)/EAD;
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
if C>0 then delete;
if RR>1 or RR<0 then delete;
if RT<12 then CRT=0;
else CRT=1;
if RR=0 then p0=1;
else p0=0;
run;

proc freq data=loantry;
tables CRT*p0;
run;

proc univariate data=loantry;
var p0;
histogram;run;

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
LoanStatus
;

proc stdize data=loantry reponly method=mean out=nonummiss;
var &inputsnum;
run;

proc means data=loantry noprint nway;
class occupation;
var p0;
output out=level mean=p0;
run;

proc cluster data=level method=ward outtree=fortree;
freq _freq_;
var p0;
id occupation;
run;

data loanmodel;
set nonummiss;
array x{*} &inputschar;
do i=1 to dim(x);
if x{i}=' ' then x{i}='N';end;
drop i;
run;
proc contents data=loanmodel;
run;

data modela;
set loanmodel;
if CRT=1;
run;

proc logistic data=modela;
class &inputschar;
model p0= &inputsnum &inputschar/selection=backward fast slstay=0.01;
run;

data modelb1;
set modela;
if RR=0 then delete;
YY=log(RR/(1-RR));
YY2=-log(-log(RR));
run;


proc glmselect data=modelb1 ;
     class &inputschar/split;  
     model YY= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=b1;
run;

proc glmselect data=modelb1 ;
     class &inputschar/split;  
     model YY2= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=b2;
run;

ods output ParameterEstimates=ParaEst;
proc univariate data=modelb1; 
var RR;   
histogram RR / beta   ctext  = blue; 
run;

proc rank data=modelb1 out=sort;
    var RR;
	ranks r_RR;
run;

proc sql noprint;
select estimate into :para1-:para6 from ParaEst;
select count(*) into :nb1 from sort;
quit;

data modelb2;
set sort;
pb=probbeta(RR,&para3,&para4);
YY3=probit(pb);
YY4=probit(r_RR/(&nb1+1));
run;

proc glmselect data=modelb2 ;
     class &inputschar/split;  
     model YY3= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=b3;
run;
proc glmselect data=modelb2 ;
     class &inputschar/split;  
     model YY4= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=b4;
run;

data modelb2;
set modelb2;
id=_n_;
run;

proc surveyselect data=modelb2 method=srs n=2000
                   seed=40070 ranuni out=modelb3 noprint;
run;

data test;
merge modelb2 modelb3(in=at);
by id;
if at then delete;
drop r_RR;
run;

data modelb3;
set modelb3;
drop r_RR;
run;

proc rank data=modelb3 out=sort2;
    var RR;
	ranks r_RR;
run;

ods output ParameterEstimates=ParaEstb;
proc univariate data=sort2;
var RR;
histogram RR/beta ctext  = blue;run;

proc sql noprint;
select estimate into :parab1-:parab6 from ParaEstb;
select count(*) into :nb2 from sort2;
quit;

data train;
set sort2;
pb=probbeta(RR,&parab3,&parab4);
YY3=probit(pb);
YY4=probit(r_RR/(&nb2+1));
run;

ods output ParameterEstimates=ParaEst1;
proc glmselect data=train ;
     class &inputschar/split;  
     model YY= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=t1;
run;
ods output ParameterEstimates=ParaEst2;
proc glmselect data=train ;
     class &inputschar/split;  
     model YY2= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=t2;
run;
ods output ParameterEstimates=ParaEst3;
proc glmselect data=train ;
     class &inputschar/split;  
     model YY3= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=t3;
run;
ods output ParameterEstimates=ParaEst4;
proc glmselect data=train ;
     class &inputschar/split;  
     model YY4= &inputschar &inputsnum/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=t4;
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

data test;
set test;
Int=1;
CurrentlyInGroup_False=(CurrentlyInGroup='False');
EmploymentStatus_Employed=(EmploymentStatus='Employed');
EmploymentStatus_FT=(EmploymentStatus='Full-time');
EmploymentStatus_N=(EmploymentStatus='N');
EmploymentStatus_NA=(EmploymentStatus='Not available');
IncomeRange_ND=(IncomeRange='Not displayed');
LoanStatus_Chargedoff=(LoanStatus='Chargedoff');
run;

%let tv1=
EmploymentStatus_Employed
EmploymentStatus_FT
EmploymentStatus_NA
LoanStatus_Chargedoff
BorrowerAPR_num
BorrowerRate_num
CreditScoreRangeLower_num
CurrentDelinquencies_num
DelinquenciesLast7Years_num
EstimatedLoss_num
Investors_num
LP_CollectionFees_num
LP_GrossPrincipalLoss_num
LP_NetPrincipalLoss_num
LP_NonPrincipalRecoverypay_num
LoanCurrentDaysDelinquent_num
LoanFirstDefaultedCycleNum_num
LoanMonthsSinceOrigination_num
LoanNumber_num
MonthlyLoanPayment_num
ProsperRating__numeric
T
Term_num
TotalInquiries_num
TradesNeverDelinquentpercent_num
TradesOpenedLast6Months_num
;
%let tv2=
CurrentlyInGroup_False
EmploymentStatus_NA
IncomeRange_ND
BorrowerAPR_num
BorrowerRate_num
CreditScoreRangeLower_num
DateCreditPulled_num
EstimatedLoss_num
LP_CollectionFees_num
LP_CustomerPrincipalPayments_num
LP_GrossPrincipalLoss_num
LP_NetPrincipalLoss_num
LP_NonPrincipalRecoverypay_num
LP_ServiceFees_num
LenderYield_num
LoanCurrentDaysDelinquent_num
LoanFirstDefaultedCycleNum_num
LoanMonthsSinceOrigination_num
LoanNumber_num
MonthlyLoanPayment_num
Recommendations_num
T
Term_num
TotalInquiries_num
TradesNeverDelinquentpercent_num
TradesOpenedLast6Months_num
;
%let tv3=
EmploymentStatus_Employed
EmploymentStatus_FT
EmploymentStatus_N
LoanStatus_Chargedoff
BorrowerAPR_num
BorrowerRate_num
CreditScoreRangeLower_num
CurrentDelinquencies_num
EstimatedLoss_num
LP_CollectionFees_num
LP_GrossPrincipalLoss_num
LP_NetPrincipalLoss_num
LP_NonPrincipalRecoverypay_num
LP_ServiceFees_num
LenderYield_num
LoanCurrentDaysDelinquent_num
LoanFirstDefaultedCycleNum_num
LoanMonthsSinceOrigination_num
LoanNumber_num
MonthlyLoanPayment_num
T
Term_num
TotalInquiries_num
TradesNeverDelinquentpercent_num
TradesOpenedLast6Months_num
;
%let tv4=
EmploymentStatus_Employed
EmploymentStatus_FT
EmploymentStatus_N
LoanStatus_Chargedoff
BorrowerAPR_num
BorrowerRate_num
CreditScoreRangeLower_num
DelinquenciesLast7Years_num
EstimatedLoss_num
LP_CollectionFees_num
LP_GrossPrincipalLoss_num
LP_NetPrincipalLoss_num
LP_NonPrincipalRecoverypay_num
LP_ServiceFees_num
LenderYield_num
LoanCurrentDaysDelinquent_num
LoanFirstDefaultedCycleNum_num
LoanMonthsSinceOrigination-num
LoanNumber_num
MonthlyLoanPayment_num
T
Term_num
TotalInquiries_num
TradesNeverDelinquentpercent_num
TradesOpenedLast6Months_num
;

%macro tests();
data test1;
set test;
array c1{&dima.} coe1-coe%left(&dima.);
array py{&dima.} py1-py%left(&dima.);
array var1{*} Int &&tv1;
%do i=1 %to &dima.;
c1{&i}=&&esta&i;
py{&i}=c1{&i}*var1{&i};
%end;
pyy1=sum(py1-py%left(&dima.));
prr1=exp(pyy1)/(1+exp(pyy1));
rsq1=(prr1-RR)**2;
keep pyy1 &&tv1 prr1 rsq1;
run;

data test2;
set test;
array c2{&dimb.} coe1-coe%left(&dimb.);
array py{&dimb.} py1-py%left(&dimb.);
array var2{*} Int &&tv2;
%do i=1 %to &dimb.;
c2{&i}=&&estb&i;
py{&i}=c2{&i}*var2{&i};
%end;
pyy2=sum(py1-py%left(&dimb.));
prr2=exp(-exp(-pyy2));
rsq2=(prr2-RR)**2;
keep pyy2 &&tv2 prr2 rsq2;
run;

data test3;
set test;
array c3{&dimc.} coe1-coe%left(&dimc.);
array py{&dimc.} py1-py%left(&dimc.);
array var3{*} Int &&tv3;
%do i=1 %to &dimc.;
c3{&i}=&&estc&i;
py{&i}=c3{&i}*var3{&i};
%end;
pyy3=sum(py1-py%left(&dimc.));
prr3=betainv(probnorm(pyy3),&&parab3,&&parab4);
rsq3=(prr3-RR)**2;
keep pyy3 &&tv3 prr3 rsq3;
run;
%mend tests;
%tests;

proc sql noprint;
select sqrt(mean(rsq1)) into :r1 from test1;
select sqrt(mean(rsq2)) into :r2 from test2;
select sqrt(mean(rsq3)) into :r3 from test3;
quit;
%put &r1 &r2 &r3;
