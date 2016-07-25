taus <- a$sol[1,]
hold<-data.matrix(hold)
pred_nnn <- exp(t(hold %*% a$sol[c(2:20),]))
write.csv(pred_nnn,'pred_nnn.csv')
plot()
pred_spl1<- smooth.spline(data.frame(pred_nnn[,1], taus))
predict(pred_spl1, 12)
pred_spl2<- smooth.spline(data.frame(pred_nnn[,2], taus))
predict(pred_spl2, 12)
