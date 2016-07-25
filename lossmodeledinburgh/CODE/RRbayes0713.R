#install.packages('bayesQR')
library(bayesQR)
#**************************input data***********************************#
#default_train<-read.csv('E:/STUDY/codes/sas/sasfiles/DATASET/Loan_default_train.csv')
default_train<-read.csv("E:/lav's/lossmodeledinburgh/Loan_default_train_try.csv")
#default_hold<-read.csv('E:/STUDY/codes/sas/sasfiles/DATASET/Loan_default_hold.csv')
#***********************************************************************#
out<-bayesQR(p0~ProsperRating__numeric+
ListingCategory__numeric+   
TotalCreditLinespast7years_num+
OpenRevolvingAccounts_num+   
CurrentDelinquencies_num+
DelinquenciesLast7Years_num+ 
BankcardUtilization_num+
TradesNeverDelinquentpercent_num+   
LoanOriginalAmount_num+  
MonthlyLoanPayment_num+ 
Investors_num+
CreditHistory_Byear+   
clu_ES_1ind+
clu_ES_2ind+
CurrentlyInGroup_Find+
IR_1ind+
IR_2ind+
IncomeVerifiable_Find ,data=default_train,quantile=seq(.1,.9,0.1),ndraw=2000)
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
#write.csv(para,'E:/STUDY/codes/sas/sasfiles/DATASET/para0713.csv')
write.csv(para,"E:/lav's/lossmodeledinburgh/lossedinbergh/para0713.csv")
#********************************************************************#
par(mfrow=c(5,4))
plot(out,var="ProsperRating__numeric",credint=c(0.1,0.9),plottype="quantile",ylab="ProsperRating__numeric")
plot(out,var="ListingCategory__numeric",credint=c(0.1,0.9),plottype="quantile",ylab="ListingCategory__numeric")
plot(out,var="TotalCreditLinespast7years_num",credint=c(0.1,0.9),plottype="quantile",ylab="TotalCreditLinespast7years_num")
plot(out,var="OpenRevolvingAccounts_num",credint=c(0.1,0.9),plottype="quantile",ylab="OpenRevolvingAccounts_num")
plot(out,var="CurrentDelinquencies_num",credint=c(0.1,0.9),plottype="quantile",ylab="CurrentDelinquencies_num")
plot(out,var="DelinquenciesLast7Years_num",credint=c(0.1,0.9),plottype="quantile",ylab="DelinquenciesLast7Years_num")
plot(out,var="BankcardUtilization_num",credint=c(0.1,0.9),plottype="quantile",ylab="BankcardUtilization_num")
plot(out,var="TradesNeverDelinquentpercent_num",credint=c(0.1,0.9),plottype="quantile",ylab="TradesNeverDelinquentpercent_num")
plot(out,var="LoanOriginalAmount_num",credint=c(0.1,0.9),plottype="quantile",ylab="LoanOriginalAmount_num")
plot(out,var="MonthlyLoanPayment_num",credint=c(0.1,0.9),plottype="quantile",ylab="MonthlyLoanPayment_num")
plot(out,var="Investors_num",credint=c(0.1,0.9),plottype="quantile",ylab="Investors_num")
plot(out,var="CreditHistory_Byear",credint=c(0.1,0.9),plottype="quantile",ylab="CreditHistory_Byear")
plot(out,var="clu_ES_1ind",credint=c(0.1,0.9),plottype="quantile",ylab="clu_ES_1ind")
plot(out,var="clu_ES_2ind",credint=c(0.1,0.9),plottype="quantile",ylab="clu_ES_2ind")
plot(out,var="CurrentlyInGroup_Find",credint=c(0.1,0.9),plottype="quantile",ylab="CurrentlyInGroup_Find")
plot(out,var="IR_1ind",credint=c(0.1,0.9),plottype="quantile",ylab="IR_1ind")
plot(out,var="IR_2ind",credint=c(0.1,0.9),plottype="quantile",ylab="IR_2ind")
plot(out,var="IncomeVerifiable_Find",credint=c(0.1,0.9),plottype="quantile",ylab="IncomeVerifiable_Find")




out













