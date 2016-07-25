library(xtable)
#install.packages("xtable")
logres<-read.csv("E:/lav's/lossmodeledinburgh/lossedinbergh/logreg.csv")
xtable(logres)

qres<-read.csv("E:/lav's/lossmodeledinburgh/lossedinbergh/para0713.csv")
xtable(qres)

kslog<-read.csv("E:/lav's/lossmodeledinburgh/lossedinbergh/kslog.csv")
xtable(kslog)