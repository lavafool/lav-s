install.packages('bayesQR')
library(bayesQR)
#**************************input data***********************************#
default_train<-read.csv("E:/lav's/DATASET/CHEN/Loan_default_train.csv")
#default_hold<-read.csv('E:/lav's/DATASET/CHEN/Loan_default_hold.csv')
#***********************************************************************#
out<-bayesQR(p0~CurrentlyInGroup_Find+
               IR_1ind+IR_2ind+
               ListingCategory__numeric+
               OpenRevolvingMonthlyPayment_num+
               TotalInquiries_num+
               AmountDelinquent_num+
               RevolvingCreditBalance_num+
               BankcardUtilization_num+
               TradesNeverDelinquentpercent_num+
               DebtToIncomeRatio_num+
               LoanOriginalAmount_num+
               MonthlyLoanPayment_num+
               InvestmentFromFriendsCount_num+
               Investors_num+
               CreditHistory_Byear,data=default_train,quantile=seq(.1,.9,0.1),ndraw=2000)
squant<-summary(out,burnin=1000)

#***********************************************************************#

#**************write the parameter estimate out***********************#
wl<-list()
for (i in 1:length(squant)){
  value=squant[[i]]$betadraw
  quantile=squant[[i]]$quantile
  c=rbind(value,quantile)
  wl[[i]]<-list(c,i)
}
#wl
para<-data.frame(wl)
write.csv(para,"E:/lav's/DATASET/CHEN/para6_7.csv")
#********************************************************************#
par(mfrow=c(4,4))
plot(out,var="CurrentlyInGroup_Find",credint=c(0.1,0.9),plottype="quantile",ylab="CurrentlyInGroup_Find")
plot(out,var="IR_1ind",credint=c(0.1,0.9),plottype="quantile",ylab="IR_1ind")
plot(out,var="IR_2ind",credint=c(0.1,0.9),plottype="quantile",ylab="IR_2ind")
plot(out,var="ListingCategory__numeric",credint=c(0.1,0.9),plottype="quantile",ylab="ListingCategory__numeric")
plot(out,var="OpenRevolvingMonthlyPayment_num",credint=c(0.1,0.9),plottype="quantile",ylab="OpenRevolvingMonthlyPayment_num")
plot(out,var="TotalInquiries_num",credint=c(0.1,0.9),plottype="quantile",ylab="TotalInquiries_num")
plot(out,var="AmountDelinquent_num",credint=c(0.1,0.9),plottype="quantile",ylab="AmountDelinquent_num")
plot(out,var="RevolvingCreditBalance_num",credint=c(0.1,0.9),plottype="quantile",ylab="RevolvingCreditBalance_num")
plot(out,var="BankcardUtilization_num",credint=c(0.1,0.9),plottype="quantile",ylab="BankcardUtilization_num")
plot(out,var="TradesNeverDelinquentpercent_num",credint=c(0.1,0.9),plottype="quantile",ylab="TradesNeverDelinquentpercent_num")
plot(out,var="DebtToIncomeRatio_num",credint=c(0.1,0.9),plottype="quantile",ylab="DebtToIncomeRatio_num")
plot(out,var="LoanOriginalAmount_num",credint=c(0.1,0.9),plottype="quantile",ylab="LoanOriginalAmount_num")
plot(out,var="MonthlyLoanPayment_num",credint=c(0.1,0.9),plottype="quantile",ylab="MonthlyLoanPayment_num")
plot(out,var="InvestmentFromFriendsCount_num",credint=c(0.1,0.9),plottype="quantile",ylab="InvestmentFromFriendsCount_num")
plot(out,var="Investors_num",credint=c(0.1,0.9),plottype="quantile",ylab="Investors_num")
plot(out,var="CreditHistory_Byear",credint=c(0.1,0.9),plottype="quantile",ylab="CreditHistory_Byear")



















