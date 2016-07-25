libname W "E:\lav's\DATASET";
DATA QUANTILE_PRE1;
SET w.loan_default_hold(
keep=
p0
loankey
CurrentlyInGroup_Find
IR_1ind
IR_2ind
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
CreditHistory_Byear
)
;
Q01=-8.386365014254+CurrentlyInGroup_Find*1.68471148767435+IR_1ind*1.01439380174315+IR_2ind*1.31045888214573+ListingCategory__numeric*0.112789147195391+OpenRevolvingMonthlyPayment_num*-0.000232056662219108+TotalInquiries_num*0.00124560449323319+AmountDelinquent_num*0.000023329450618943+RevolvingCreditBalance_num*1.14010252085505E-05+BankcardUtilization_num*-0.775521457126937+TradesNeverDelinquentpercent_num*3.27493185327867+DebtToIncomeRatio_num*0.162271380132391+LoanOriginalAmount_num*-0.00116176804054564+MonthlyLoanPayment_num*0.0279263558351709+InvestmentFromFriendsCount_num*0.16737335717465+Investors_num*0.00369694962013132+CreditHistory_Byear*-0.00352110481600797;
Q02=-3.69113490680489+CurrentlyInGroup_Find*0.854820781885782+IR_1ind*0.494798322042967+IR_2ind*0.637445467812031+ListingCategory__numeric*0.0584147656817123+OpenRevolvingMonthlyPayment_num*-1.50103905417865E-05+TotalInquiries_num*0.000422101062148838+AmountDelinquent_num*1.80276575197894E-05+RevolvingCreditBalance_num*4.68935587215248E-06+BankcardUtilization_num*-0.393367243830988+TradesNeverDelinquentpercent_num*1.71240721212918+DebtToIncomeRatio_num*0.065683146390526+LoanOriginalAmount_num*-0.000622948158442266+MonthlyLoanPayment_num*0.0153152841329543+InvestmentFromFriendsCount_num*0.166062379334018+Investors_num*0.00170844665248664+CreditHistory_Byear*-0.0019514179589743;
Q03=-2.03924863083304+CurrentlyInGroup_Find*0.575264845609622+IR_1ind*0.312024979741859+IR_2ind*0.430211087572742+ListingCategory__numeric*0.0429368112461012+OpenRevolvingMonthlyPayment_num*1.20193692464754E-06+TotalInquiries_num*-0.00129544008858911+AmountDelinquent_num*1.62602138165639E-05+RevolvingCreditBalance_num*3.68398483827368E-06+BankcardUtilization_num*-0.303855707402544+TradesNeverDelinquentpercent_num*1.2123192287809+DebtToIncomeRatio_num*0.0325808994744201+LoanOriginalAmount_num*-0.000459901041571458+MonthlyLoanPayment_num*0.0114416081257541+InvestmentFromFriendsCount_num*0.178552719409986+Investors_num*0.00116812160051695+CreditHistory_Byear*-0.00137010373897113;
Q04=-1.19191048956238+CurrentlyInGroup_Find*0.447691443473317+IR_1ind*0.210037968283087+IR_2ind*0.317213338594015+ListingCategory__numeric*0.0488967027141134+OpenRevolvingMonthlyPayment_num*-2.05357686646041E-05+TotalInquiries_num*-0.000781396123322775+AmountDelinquent_num*0.000018613000098786+RevolvingCreditBalance_num*3.48237318417586E-06+BankcardUtilization_num*-0.268238586892664+TradesNeverDelinquentpercent_num*0.982083591282614+DebtToIncomeRatio_num*0.0315517789358215+LoanOriginalAmount_num*-0.000390118130613531+MonthlyLoanPayment_num*0.00980331098117941+InvestmentFromFriendsCount_num*0.153950492347562+Investors_num*0.00102115666830066+CreditHistory_Byear*-0.00114958054165975;
Q05=-0.664232267381616+CurrentlyInGroup_Find*0.415296362744536+IR_1ind*0.199521634361149+IR_2ind*0.29965274369668+ListingCategory__numeric*0.0583663348036015+OpenRevolvingMonthlyPayment_num*-2.64088000532449E-05+TotalInquiries_num*-0.00160988053992097+AmountDelinquent_num*1.80350052403697E-05+RevolvingCreditBalance_num*3.31813014560413E-06+BankcardUtilization_num*-0.286511741611463+TradesNeverDelinquentpercent_num*0.924192501322055+DebtToIncomeRatio_num*0.0304677534572681+LoanOriginalAmount_num*-0.000388401392197534+MonthlyLoanPayment_num*0.00995660705183699+InvestmentFromFriendsCount_num*0.146443126619306+Investors_num*0.000987611722092935+CreditHistory_Byear*-0.00113937559853062;
Q06=-0.273372786571664+CurrentlyInGroup_Find*0.496972316780895+IR_1ind*0.202952977709393+IR_2ind*0.350622453501921+ListingCategory__numeric*0.0799305755563605+OpenRevolvingMonthlyPayment_num*-2.01040490403193E-05+TotalInquiries_num*-0.00188010064342542+AmountDelinquent_num*2.13687429832887E-05+RevolvingCreditBalance_num*4.08261127706015E-06+BankcardUtilization_num*-0.359112784880549+TradesNeverDelinquentpercent_num*1.05185054807356+DebtToIncomeRatio_num*0.0462543449366312+LoanOriginalAmount_num*-0.00045356676609099+MonthlyLoanPayment_num*0.0118330420443476+InvestmentFromFriendsCount_num*0.171330821443217+Investors_num*0.000888674499030159+CreditHistory_Byear*-0.0013549360171758;
Q07=0.125373101388679+CurrentlyInGroup_Find*0.642207957186193+IR_1ind*0.241622845400572+IR_2ind*0.417818014322983+ListingCategory__numeric*0.100166580112022+OpenRevolvingMonthlyPayment_num*-1.40123723098453E-05+TotalInquiries_num*-0.00238361417600808+AmountDelinquent_num*3.08101750074395E-05+RevolvingCreditBalance_num*4.60690377902692E-06+BankcardUtilization_num*-0.468416936629727+TradesNeverDelinquentpercent_num*1.44262583045811+DebtToIncomeRatio_num*0.0516647059251834+LoanOriginalAmount_num*-0.000584975562037947+MonthlyLoanPayment_num*0.0154314537205145+InvestmentFromFriendsCount_num*0.283476261833577+Investors_num*0.00100247253697434+CreditHistory_Byear*-0.0017587217961811;
Q08=0.788210656137581+CurrentlyInGroup_Find*0.982597420299131+IR_1ind*0.419120461527457+IR_2ind*0.73596931425304+ListingCategory__numeric*0.17251771414166+OpenRevolvingMonthlyPayment_num*-1.29680063258606E-06+TotalInquiries_num*-0.0018981591514417+AmountDelinquent_num*4.60764785604503E-05+RevolvingCreditBalance_num*7.07733836643655E-06+BankcardUtilization_num*-0.759738720238644+TradesNeverDelinquentpercent_num*2.19147608213256+DebtToIncomeRatio_num*0.0736171456188651+LoanOriginalAmount_num*-0.000872160780101153+MonthlyLoanPayment_num*0.0231533074138298+InvestmentFromFriendsCount_num*0.42474831101358+Investors_num*0.00123905446057126+CreditHistory_Byear*-0.00274228290595171;
Q09=2.82977917488197+CurrentlyInGroup_Find*1.86133180762724+IR_1ind*0.842255297725811+IR_2ind*1.45639119377583+ListingCategory__numeric*0.315367396622679+OpenRevolvingMonthlyPayment_num*-9.74533596275565E-05+TotalInquiries_num*-0.00838442238252839+AmountDelinquent_num*8.92103660409178E-05+RevolvingCreditBalance_num*1.48981826122223E-05+BankcardUtilization_num*-1.57820609607054+TradesNeverDelinquentpercent_num*4.37127802282014+DebtToIncomeRatio_num*0.181010719817379+LoanOriginalAmount_num*-0.00173896779214112+MonthlyLoanPayment_num*0.0460404317138007+InvestmentFromFriendsCount_num*0.841404238002797+Investors_num*0.00263459787363506+CreditHistory_Byear*-0.00486744655963118;
run;
/*proc export data=QUANTILE_PRE1*/
/*outfile="C:\Users\Admin\Desktop\loan\RRinclude0\dataset\precheck"*/
/*dbms=csv*/
/*replace;*/
/*run;*/

DATA QUANTILE_PRE;
SET QUANTILE_PRE1;
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
outfile="E:\lav's\DATASET\codes\chen\01rrcode\prdct_quantile_next.csv"
dbms=csv
replace;
run;


ods printer pdf file="E:\lav's\DATASET\codes\chen\01rrcode\out_npar1way_quantile.pdf";
ods graphics on;
proc npar1way edf wilcoxon data=QUANTILE_PRE_NEXT plots=(wilcoxonboxplot medianplot edfplot);
class p0;
var quantpred;
run;
ods graphics off;
ods printer pdf close;
