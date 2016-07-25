library(survival)
setwd("C:/survana")
train<-read.csv("C:/survana/Loan_credit_total1_train1000.csv")
hold<-read.csv("C:/survana/Loan_credit_total1_hold400.csv")
x<-cbind(1,hold)
base<-read.csv("C:/survana/baseline.csv")
basex<-cbind(1,base)
cox<-coxph(Surv(surv_time,default_id)~
               CreditScoreRangeLower_num+
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
data=train)

pre1<-predict(cox,newdata=x,type="lp")
pre2<-predict(cox,newdata=x,type="risk")
pre3<-predict(cox,newdata=x,type="expected")
pre4<-predict(cox,newdata=x,type="terms")
cool<-data.frame(cbind(pre1,pre2,pre3,pre4))
write.csv(cool,"pr.csv")
rmse <- sqrt(mean((x$default_id - pre3)^2))

pre_baseline<-predict(cox,newdata=basex,type="expected")

