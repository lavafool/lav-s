
proc glmselect data=rr_model2 namelen=50 ;
     class &regchars/split;
     model YY3= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
     output out=rr_m3;
run;
libname w "D:\sas\sasfiles\DATASET";

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
firstCreditline_y;

%let regchars=
EmploymentStatus
IsBorrowerHomeowner
CurrentlyInGroup
IncomeRange
IncomeVerifiable;


data rr_model;
set w.loan_credit_rr_train;
YY=log(RR/(1-RR));
YY2=-log(-log(RR));
run;


proc glmselect data=rr_model ;
     class &regchars/split;  
     model YY= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m1;
run;

proc glmselect data=rr_model namelen=50;
     class &regchars/split;  
     model YY2= &regchars &regnums/SELECTION=BACKWARD CHOOSE=cp SHOWPVALUES ;
	 output out=rr_m2;
	 run;
 
proc univariate data=rr_model ; 
var RR;   
histogram RR / beta   ctext  = blue; 
run;

proc rank data=rr_model out=rr_rank;
    var RR;
	ranks r_RR;
run;


data rr_model2;
set rr_rank;
pb=probbeta(RR,0.25,0.24);
YY3=probit(pb);
YY4=probit(r_RR/2324);
run;

proc glmselect data=rr_model2 namelen=50 ;
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
EmploymentStatus_Employed=(EmploymentStatus='Employed');
EmploymentStatus_FT=(EmploymentStatus='Full-time'); 
EmploymentStatus_NA=(EmploymentStatus='Not available'); 
EmploymentStatus_Other=(EmploymentStatus='Other'); 
EmploymentStatus_PT=(EmploymentStatus='Part-time');
EmploymentStatus_Retired=(EmploymentStatus='Retired');
EmploymentStatus_NE=(EmploymentStatus='Not employed'); 
IncomeRange_100000=(IncomeRange='$100,000+');
IncomeRange_1_24999=(IncomeRange='$1-24,999');
IncomeRange_25000_49999=(IncomeRange='$25,000-49,999');
IncomeRange_50000_74999=(IncomeRange='$50,000-74,999');
IncomeRange_75000_99999=(IncomeRange='$75,000-99,999');
IncomeRange_ND=(IncomeRange='Not displayed');
CurrentlyInGroup_False=(CurrentlyInGroup='False');
run;

%let tv1=

EmploymentStatus_FT
EmploymentStatus_NA
EmploymentStatus_PT
EmploymentStatus_Retired
CurrentlyInGroup_False
IncomeRange_ND
ProsperRating__numeric
TotalInquiries_num
CurrentDelinquencies_num
AmountDelinquent_num
TradesNeverDelinquentpercent_num
DebtToIncomeRatio_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
InvestmentFromFriendsCount_num
InvestmentFromFriendsAmount_num
Investors_num
firstcreditline_y
;

%let tv2=

EmploymentStatus_Employed
EmploymentStatus_FT
EmploymentStatus_NA
EmploymentStatus_Other
EmploymentStatus_PT
EmploymentStatus_Retired
CurrentlyInGroup_False
IncomeRange_ND
ProsperRating__numeric
TotalInquiries_num
CurrentDelinquencies_num
TradesNeverDelinquentpercent_num
DebtToIncomeRatio_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
InvestmentFromFriendsCount_num
Investors_num
firstcreditline_y;

%let tv3=
EmploymentStatus_FT
EmploymentStatus_NA
EmploymentStatus_PT
EmploymentStatus_Retired
CurrentlyInGroup_False
IncomeRange_ND
ProsperRating__numeric
TotalInquiries_num
CurrentDelinquencies_num
AmountDelinquent_num
TradesNeverDelinquentpercent_num
DebtToIncomeRatio_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
InvestmentFromFriendsCount_num
InvestmentFromFriendsAmount_num
Investors_num
firstcreditline_y
;

%let tv4=
EmploymentStatus_FT
EmploymentStatus_NA
EmploymentStatus_PT
CurrentlyInGroup_False
IncomeRange_ND
ProsperRating__numeric
InquiriesLast6Months_num
CurrentDelinquencies_num
AmountDelinquent_num
TradesNeverDelinquentpercent_num
TradesOpenedLast6Months_num
DebtToIncomeRatio_num
LoanOriginalAmount_num
MonthlyLoanPayment_num
firstcreditline_y
;


data test1;
set rr_test;
array c{19} coe1-coe19(2.319159,2.013318,4.126832,2.730655,2.780907,0.583592,-2.978405,-0.505662,-0.028067,-0.100895,-0.000030701,-1.674215,0.419361,0.001354,-0.041645,-0.921568,0.000581,-0.00424,0.041573);

array py{19} py1-py19;
array var1{*} Int &tv1;
do i=1 to dim(var1);
py{i}=c{i}*var1{i};
end;
pyy1=sum(py1-py19);
prr1=exp(pyy1)/(1+exp(pyy1));
rsq1=(prr1-RR)**2;
keep pyy1 &tv1 prr1 rsq1;
run;


data test2;
set rr_test;
array c2{19} coe1-coe19(3.966952,-0.903191,1.195631,2.796278,-1.785774,1.899788,2.309162,0.409105,-1.969115,-0.43562,-0.023752,-0.07318,-1.392251,0.348741,0.001282,-0.038452,-0.680394,-0.004507,0.02714
);
array py{19} py1-py19;
array var2{*} Int &tv2;
do i=1 to dim(var2);
py{i}=c2{i}*var2{i};
end;
pyy2=sum(py1-py19);
prr2=exp(-exp(-pyy2));
rsq2=(prr2-RR)**2;
keep pyy2 &tv2 prr2 rsq2;
run;
data test3;
set rr_test;
array c2{19} coe1-coe19(0.221057,0.314714,0.667733,0.399925,0.368257,0.104331,-0.513593,-0.078095,-0.004797,-0.017521,-0.000005752,-0.258991,0.064762,0.000197,-0.006188,-0.135612,0.000090839,-0.000557,0.007132);
array py{19} py1-py19;
array var3{*} Int &tv3;
do i=1 to dim(var3);
py{i}=c2{i}*var3{i};
end;
pyy3=sum(py1-py19);
prr3=betainv(probnorm(pyy3),0.14,0.24);
rsq3=(prr3-RR)**2;
keep pyy3 &tv3 prr3 rsq3;
run;
data test4;
set rr_test;
array c2{16} coe1-coe16(0.26901,0.187658,0.56596,0.218887,0.147471,-0.621034,-0.060292,-0.013941,-0.021719,-0.000007562,-0.232666,0.025148,0.042749,0.000107,-0.003815,0.009134);
array py{16} py1-py16;
array var4{*} Int &tv4;
do i=1 to dim(var4);
py{i}=c2{i}*var4{i};
end;
pyy4=sum(py1-py16);
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
