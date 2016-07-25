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
proc contents data=loantry;
run;
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
proc print data=level;
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

ods listing close; 
ods results off;  
ods output ParameterEstimates=ParaEst;
proc univariate data=modelb1; 
var RR;   
histogram RR / beta   ctext  = blue; 
run;
ods results on;    
ods listing;

proc rank data=modelb1 out=sort;
    var RR;
	ranks r_RR;
run;

proc sql noprint;
select estimate into :para1-:para6 from ParaEst;
select count(*) into :nb1 from sort;

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

data modelb3;
set modelb2(obs=2000);
drop r_RR;
run;
proc rank data=modelb3 out=sort2;
    var RR;
	ranks r_RR;
run;
ods listing close;
ods results off;
ods output ParameterEstimate=ParaEst;
proc univariate data=sort2;
var RR;
histogram RR/beta ctext  = blue;run;
ods results on;
ods listing;

proc sql noprint;
select estimate into :parab1-:parab6 from ParaEst;
select count(*) into :nb2 from sort2;

data train;
set sort2;
pb=probbeta(RR,&parab3,&parab4);
YY3=probit(pb);
YY4=probit(r_RR/(&nb2+1));
run;

ods listing close; 
ods results off; 
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
ods results on;
ods listing;
proc print data=ParaEst4;run;
proc sql noprint;
select estimate into :esta1-:esta27 from ParaEst1;
select estimate into :estb1-:estb27 from ParaEst2;
select estimate into :estc1-:estc26 from ParaEst3;
select estimate into :estd1-:estd26 from ParaEst4;
data test;
set modelb2(firstobs=&nb2);
Int=1;
CurrentlyInGroup_False=(CurrentlyInGroup='False');
EmploymentStatus_Employed=(EmploymentStatus='Employed');
EmploymentStatus_FT=(EmploymentStatus='Full-time');
EmploymentStatus_N=(EmploymentStatus='N');
EmploymentStatus_NA=(EmploymentStatus='Not available');
IncomeRange_ND=(IncomeRange='Not displayed');
LoanStatus_Chargedoff=(LoanStatus='Chargedoff');
if _n_~=1;
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

data test1;
set test;
array c1{27} &esta1-&esta27;
array py{27} py1-py27;
array var1{*} Int &tv1;
do i=1 to dim(var1);
py{i}=c1{i}*var1{i};
end;
pyy1=sum(py1-py27);
prr1=exp(pyy1)/(1+exp(pyy1));
rsq1=(prr1-RR)**2;
keep pyy1 &tv1 prr1 rsq1;
run;
data test2;
set test;
array c2{27} coe1-coe27(-49.694306,-0.081669,0.223349,-0.416282,10.054349,-20.444907,0.000564,0.002393,-1.363253,0.000449,0.000061279,0.000432,-0.000398,0.000402,0.001528,11.115762,-0.000329,-0.005709,0.096662,0.000012229,-0.003149,-0.135839,0.03831,-0.027011,-0.004085,-0.317159,0.026957);
array py{27} py1-py27;
array var2{*} Int &tv2;
do i=1 to dim(var2);
py{i}=c2{i}*var2{i};
end;
pyy2=sum(py1-py27);
prr2=exp(-exp(-pyy2));
rsq2=(prr2-RR)**2;
keep pyy2 &tv2 prr2 rsq2;
run;
data test3;
set test;
array c2{26} coe1-coe26(-0.940278,0.100194,0.111756,-0.204994,-0.094403,7.142506,-13.427557,0.000501,-0.011129,-1.067451,0.000285,0.000293,-0.000313,0.00036,0.000865,6.508383,-0.000206,-0.00432,0.015268,0.000008758,-0.001531,0.035504,-0.021779,-0.004931,-0.317212,0.022059);
array py{26} py1-py26;
array var3{*} Int &tv3;
do i=1 to dim(var3);
py{i}=c2{i}*var3{i};
end;
pyy3=sum(py1-py26);
prr3=betainv(probnorm(pyy3),0.48,1.19);
rsq3=(prr3-RR)**2;
keep pyy3 &tv3 prr3 rsq3;
run;

proc univariate data=test1;
var rsq1;run;
proc univariate data=test2;
var rsq2;run;
proc univariate data=test3;
var rsq3;run;
