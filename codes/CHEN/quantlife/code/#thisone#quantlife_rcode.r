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

#predicted quantiles loans:

hold<-read.csv('Loan_credit_total1_hold400cln_c.csv')
hold<-cbind(1,hold)
#hold<-data.frame(hold)
#para<- a$sol[c(2:20),]
#para<-data.frame(para)
#write.csv(para,'para.csv')
#dim(hold)
#dim(para)
#rownames(para)<-NULL
#colnames(para)<-NULL
#rownames(hold)<-NULL
#colnames(hold)<-NULL
#paramatrix<-data.matrix(para[c(1:19),c(1,8,15,22,29,36,43,50,57)])
#holdmatrix<-data.matrix(hold)
#pred1<-exp(t(holdmatrix %*% paramatrix))
#pred2<-exp(holdmatrix %*% paramatrix)
#write.csv(pred1,'pred1.csv')
#write.csv(pred2,'pred2.csv')
#turn to SAS to handle pred2 and get pred2_new
#pred2_new<-read.csv('pred2_new.csv')
#require(graphics)
#plot(pred ,tau ,main="try")

taus <- a$sol[1,]
hold<-data.matrix(hold)
#predict default time of hold-data
pred_t <- exp(t(hold %*% a$sol[c(2:20),]))
write.csv(pred_t,'pred_t.csv')

#pred_spl1<- smooth.spline(data.frame(pred_t[,1], taus))
#predict(pred_spl1, 12)
#pred_spl2<- smooth.spline(data.frame(pred_t[,184], taus))
#predict(pred_spl2, 12)

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

#lines(pred.spl1, col = "blue")
#lines(smooth.spline(pred, tau , df=8) ,lty= 2 ,col="red")


#This smooths the taus and predicted quantiles
#tau<-c(1:9/10)
#predata<-(data.frame(pred1, tau)
#write.csv(predata,'predata.csv')
#pred <- smooth.spline(data.frame(pred1, tau))


#Probability of defaulting between year 2 and 3
#predict(pred, 36)$y-predict(pred, 24)$y

#Probability of defaulting in the first year
#predict(pred, 12)$y
