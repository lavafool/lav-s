library(survival)
library(SparseM)
library(quantreg)


a <- crq(Surv(log(defaults2$count),defaults2$default)~CreditScore + CreditScore2 + 
        GroupDummy + Amount + BorrowerRate +
        BorrowerRate2 + DebtToIncomeRatio + Home + CurrentDelinquencies + 
        DelinquenciesLast7Years + InquiriesLast6Months + 
        PublicRecordsLast10Years + PublicRecordsLast12Months+
        OpenCreditLines+ CityDummy + Fulltime + BankcardUtilization + RevolvingCreditBalance 
        + AmountDelinquent+TotalCreditLines+CurrentCreditLines, 
        method="Por", taus=c(1:19/20), data=defaults2)

sfit <- summary(a, tau=1:19/20, R=500)

taus <- a$sol[1,]


##Here I get predicted quantiles for loans in the AA category for a loan of $10000. I use the average interest rate of AA loans between 9500 and 10500 for the interest rate.

High <- subset(defaults2, CreditGrade=="AA")
High <- data.frame(model.matrix(formula, data=High))
newH <- apply(High,2,mean)
newH[5] <- 10000
Hint <- subset(High, Amount > 9500 & Amount < 10500)
newH[6] <- mean(Hint$BorrowerRate)
newH[7] <- mean(Hint$BorrowerRate)^2
High[1,] <- newH


#predicted quantiles for "High type" loans:

pred1 <- exp(t(newH %*% a$sol[c(2:23),]))

#This smooths the taus and predicted quantiles

predH <- smooth.spline(data.frame(pred1, taus))

#Probability of defaulting between year 2 and 3
predict(predH, 1096)$y-predict(predH, 730)$y

#Probability of defaulting in the first year
predict(predH, 365)$y