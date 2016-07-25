install.packages('survival')
install.packages('SparseM')
install.packages('quantreg')
library(survival)
library(SparseM)
library(quantreg)
setwd("C:/Users/Admin/Desktop/loan/quantlife")
dataset<-read.csv('Loan_credit_total1_train1000cle.csv')
dataset0<-subset(dataset,surv_time!=0)
a<-crq(Surv(log(surv_time),defaultcensor_id)~CreditScoreRangeLower_num+
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
       data=dataset0, method="Por", taus=c(1:9/10)
)
sa<-summary(a,tau=c(1:9/10), R=500)  

wl<-list()
for (i in 1:length(sa)){
  value=sa[[i]]$coef
  tau=sa[[i]]$tau
  c=rbind(value,tau)
  wl[[i]]<-list(c,i)
}
para<-data.frame(wl)
write.csv(para,'para.csv')

plot(sa)

hold<-read.csv('Loan_credit_total1_hold400cln_c.csv')
hold<-cbind(1,hold)

taus <- a$sol[1,]
hold<-data.matrix(hold)
#predict default time of hold-data
pred_t <- exp(t(hold %*% a$sol[c(2:20),]))
write.csv(pred_t,'pred_t.csv')

#define x a matrix to put the default prob of hold-data
x<-matrix(rep(0),nrow=400,ncol=3)
for (j in 1:3){
    TIME<-6*j
  for (i in 1:400){pred_spl<- smooth.spline(data.frame(pred_t[,i], taus))
                   ypred<-predict(pred_spl, TIME)$y
                   x[i,j]<-ypred
  }}
x<-data.frame(x)
write.csv(x,'survprob.csv')