install.packages('survival')
install.packages('SparseM')
install.packages('quantreg')
library(survival)
library(SparseM)
library(quantreg)
setwd("C:/Users/Admin/Desktop/loan/quantlife")
dataset<-read.csv('Loan_credit_total1_train10000.csv')
#hold<-read.csv('loan_credit_total1_hold.csv')
a<-crq(Surv(surv_time,defaultcensor_id)~CreditScoreRangeLower_num+
         InquiriesLast6Months_num+
         ProsperRating__numeric+
         clu_ES+
         IR+
         MonthlyLoanPayment_num+
         LoanOriginalAmount_num+
         CurrentDelinquencies_num+
         TradesOpenedLast6Months_num+
         OpenRevolvingAccounts_num+
         TotalInquiries_num+
         StatedMonthlyIncome_num+
         Investors_num+
         OpenRevolvingMonthlyPayment_num+
         EmploymentStatusDuration_num+
         BankcardUtilization_num,
       data=dataset, method="Por", taus=c(0.1,0.5,0.9)
)
sa<-summary(a,tau=c(0.1,0.5,0.9), R=500)     
wl<-list()
for (i in 1:length(sa)){
  value=sa[[i]]$coef
  tau=sa[[i]]$tau
  c=rbind(value,tau)
  wl[[i]]<-list(c,i)
}
para<-data.frame(wl)
write.csv(para,'para_20_80.csv')
plot(sa)


taus <- a$sol[1,]
High <- subset(dataset)
High <- data.frame(model.matrix(formula, data=High))
newH <- apply(High,2,mean)
newH[5] <- 10000
Hint <- subset(High, Amount > 9500 & Amount < 10500)
newH[6] <- mean(Hint$BorrowerRate)
newH[7] <- mean(Hint$BorrowerRate)^2
High[1,] <- newH