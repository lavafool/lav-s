libname W 'C:\Users\Admin\Desktop\loan\DATASET';
libname o 'C:\Users\Admin\Desktop\loan\Loss_Modeling\DATASET';
proc surveyselect data=w.loan_credit_total2 n=10000 ranuni out=LOAN_TT2SAMPLE;
RUN;
proc quantlife data=LOAN_TT2SAMPLE;
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
/quantile=(0.1 0.5 0.9);
/*test EmploymentStatus*/
/*IsBorrowerHomeowner*/
/*CurrentlyInGroup*/
/*IncomeRange*/
/*IncomeVerifiable*/
/*ProsperRating__numeric*/
/*ListingCategory__numeric*/
/*EmploymentStatusDuration_num*/
/*CreditScoreRangeLower_num*/
/*CreditScoreRangeUpper_num*/
/*CurrentCreditLines_num*/
/*TotalCreditLinespast7years_num*/
/*OpenRevolvingAccounts_num*/
/*OpenRevolvingMonthlyPayment_num*/
/*InquiriesLast6Months_num*/
/*TotalInquiries_num*/
/*CurrentDelinquencies_num*/
/*AmountDelinquent_num*/
/*DelinquenciesLast7Years_num*/
/*PublicRecordsLast10Years_num*/
/*PublicRecordsLast12Months_num*/
/*RevolvingCreditBalance_num*/
/*BankcardUtilization_num*/
/*AvailableBankcardCredit_num*/
/*TotalTrades_num*/
/*TradesNeverDelinquentpercent_num*/
/*TradesOpenedLast6Months_num*/
/*DebtToIncomeRatio_num*/
/*StatedMonthlyIncome_num*/
/*LoanOriginalAmount_num*/
/*MonthlyLoanPayment_num*/
/*Recommendations_num*/
/*InvestmentFromFriendsCount_num*/
/*InvestmentFromFriendsAmount_num*/
/*Investors_num*/
/*firstcreditline_y;*/
run;
ods graphics off;
