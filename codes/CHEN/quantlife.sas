data w.loan_credit_total2;
set w.loan_credit_total1;
if ProsperRating__numeric=. then ProsperRating__numeric=2.8300836;
if ListingCategory__numeric=. then ListingCategory__numeric=1.8290021;
if EmploymentStatusDuration_num=. then EmploymentStatusDuration_num=82.8363114;
if CreditScoreRangeLower_num=. then CreditScoreRangeLower_num=637.5821288;
if CreditScoreRangeUpper_num=. then CreditScoreRangeUpper_num=656.5821288;
if CurrentCreditLines_num=. then CurrentCreditLines_num=9.2392344;
if TotalCreditLinespast7years_num=. then TotalCreditLinespast7years_num=26.3529257;
if OpenRevolvingAccounts_num=. then OpenRevolvingAccounts_num=5.3809771;
if OpenRevolvingMonthlyPayment_num=. then OpenRevolvingMonthlyPayment_num=306.2887214;
if InquiriesLast6Months_num=. then InquiriesLast6Months_num=3.0450712;
if TotalInquiries_num=. then TotalInquiries_num=9.8914027;
if CurrentDelinquencies_num=. then CurrentDelinquencies_num=1.5440169;
if AmountDelinquent_num=. then AmountDelinquent_num=1361.55;
if DelinquenciesLast7Years_num=. then DelinquenciesLast7Years_num=7.2700478;
if PublicRecordsLast10Years_num=. then PublicRecordsLast10Years_num=0.4599367;
if PublicRecordsLast12Months_num=. then PublicRecordsLast12Months_num=0.0440191;
if RevolvingCreditBalance_num=. then RevolvingCreditBalance_num=14742;
if BankcardUtilization_num=. then BankcardUtilization_num=0.5799522;
if AvailableBankcardCredit_num=. then AvailableBankcardCredit_num=6116.58;
if TotalTrades_num=. then TotalTrades_num=22.1470869;
if TradesNeverDelinquentpercent_num=. then TradesNeverDelinquentpercent_num=0.7828335;
if TradesOpenedLast6Months_num=. then TradesOpenedLast6Months_num=1.1072907;
if DebtToIncomeRatio_num=. then DebtToIncomeRatio_num=0.3217608;
if StatedMonthlyIncome_num=. then StatedMonthlyIncome_num=4581.15;
if LoanOriginalAmount_num=. then LoanOriginalAmount_num=6517.45;
if MonthlyLoanPayment_num=. then MonthlyLoanPayment_num=232.7055899;
if Recommendations_num=. then Recommendations_num=0.0899168;
if InvestmentFromFriendsCount_num=. then InvestmentFromFriendsCount_num=0.0392412;
if InvestmentFromFriendsAmount_num=. then InvestmentFromFriendsAmount_num=31.8820894;
if Investors_num=. then Investors_num=103.3069127;
if EmploymentStatus=' ' then EmploymentStatus='Full-time';
firstcreditline_y=intck('year',FirstRecordedCreditLine_num,loanoriginationdate_num);
if firstcreditline_y=. then firstcreditline_y=14.8070638;
run;
ods graphics on;
proc quantlife data=w.loan_credit_total2;
class EmploymentStatus
IsBorrowerHomeowner
CurrentlyInGroup
IncomeRange
IncomeVerifiable;
model surv_time*defaultcensor_id(0)=
/***********attribute variable***********/
EmploymentStatus
IsBorrowerHomeowner
CurrentlyInGroup
IncomeRange
IncomeVerifiable
/***********numerical variable***********/
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
firstcreditline_y
/quantile=0.1 0.5 0.9;
test EmploymentStatus
IsBorrowerHomeowner
CurrentlyInGroup
IncomeRange
IncomeVerifiable
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
firstcreditline_y;
run;
ods graphics off;
