library(quantreg)
rr_train<-read.csv('C:/Users/Admin/Desktop/loan/RRlagerthan0_program/dataset/Loan_credit_rr_train.csv')
rr_hold<-read.csv('C:/Users/Admin/Desktop/loan/RRlagerthan0_program/dataset/Loan_credit_rr_hold.csv')
x<-cbind(1,rr_hold)
quantreg<-rq(RR~ListingCategory__numeric+
             EmploymentStatusDuration_num+
             TotalCreditLinespast7years_num+
             CurrentDelinquencies_num+
             RevolvingCreditBalance_num+
             AvailableBankcardCredit_num+
             TradesNeverDelinquentpercent_num+
             LoanOriginalAmount_num+
             MonthlyLoanPayment_num+
             CreditHistory_Byear+
             clu_ES+
             CurrentlyInGroup+
             IR_1ind+IR_2ind+
             IncomeVerifiable
             ,data=rr_train,tau=seq(.1,.9,.1))
squantreg<-summary(quantreg)
squantreg
wl<-list()
for (i in 1:length(squantreg)){
  value=squantreg[[i]]$coef
  tau=squantreg[[i]]$tau
  c=rbind(value,tau)
  wl[[i]]<-list(c,i)
}
para<-data.frame(wl)
write.csv(para,'C:/Users/Admin/Desktop/loan/RRlagerthan0_program/dataset/para.csv')

pre_rr_hold<-predict(quantreg,newdata=x)
write.csv(pre_rr_hold,'C:/Users/Admin/Desktop/loan/RRlagerthan0_program/dataset/pre_rr_hold9.csv')
plot(quantreg,par=c(2,3,4,5,6,7,8,9,10))
plot(quantreg,par=c(11,12,13,14,15,16,17))

