#pre-setting of Lee-Carter model building 
library(demography)
library(StMoMo)
USDemo<-read.demogdata('data/Mx_1x1.txt','data/Exposures_1x1.txt', type="mortality", label="U.S.A")
USDemoF<-StMoMoData(USDemo, series = "female")


#=======================================FEMALE===============================================
USDemoF<-StMoMoData(USDemo, series = "female")

nfuture=60
LCfit <- fit(lc(),data = USDemoF,ages.fit = 0:90,years.fit = 1933:2015)
LCfor<-forecast(LCfit, h=nfuture)

#import result of predicted testing values from TRMF method
TRMF.future <- read.csv("TRMF_future.csv",header = F)
#TRMF method with normalization method

TRMFratesF<-cbind(log(USDemo$rate$female[1:91,]),TRMF.future[1:91,])
ratesF<-log(cbind(USDemo$rate$female[1:91,],LCfor$rates[1:91,]))

#=======================================Figure_10_Older===========================================

##pre-set of legend -->use if want to build legend outside the graph (on the right)
#par(xpd=T, mar=c(5, 4, 4, 2)+c(0,1,0,7))
#par()
#par(xpd=TRUE)
pdf("Figure_12_Old.pdf", width=6, height=10)
#plot for future older ages
plot(seq(min(USDemo$year),2015),TRMFratesF[61,1:83],
     xlab="Years",ylab="Log Death Rates",type="l",col="red",lty=1, xlim=c(1933,2075), 
     ylim = c(-7,-2),lwd=1,cex.lab=1.3,cex.axis=1.3)
lines(seq(2015,2015+nfuture),TRMFratesF[61,83:143],col="red",lty=2,
      lwd=2)
lines(seq(min(USDemo$year),2015),TRMFratesF[71,1:83],col="blue",lty=1,lwd=1)
lines(seq(2015,2015+nfuture),TRMFratesF[71,83:143],col="blue",lty=2,
      lwd=2)
lines(seq(min(USDemo$year),2015),TRMFratesF[81,1:83],col="green",lty=1,
      lwd=1)
lines(seq(2015,2015+nfuture),TRMFratesF[81,83:143],col="green",lty=2,
      lwd=2)
lines(seq(2015,2015+nfuture), ratesF[61,83:143],col="red",lty=4)
lines(seq(2015,2015+nfuture), ratesF[71,83:143],col="blue",lty=4)
lines(seq(2015,2015+nfuture), ratesF[81,83:143],col="green",lty=4)

legend("bottomleft", ncol=2, c("Age 60","Age 70","Age 80","Predict (RMF)","Predict (LC)","Actual"),
       col=c("red","blue","green","black","black","black"),lty=c(1,1,1,2,4,1),lwd=c(1,1,1,2,1,1),
       cex=1.3,bty = "n")
dev.off()
#For legend outside the plot
#legend(2080,-2.5, ncol=1, c("Age 60","Age 70","Age 80","Predict (RMF)","Predict(LC)","Actual"),
#       col=c("red","blue","black","black","black"),lty=c(1,1,1,2,4,1),lwd=c(1,1,1,2,1,1),
#       cex=1.3,bty = "n")


#=====================================Figure_10_Young==============================
#plot for future younger ages

plot(seq(min(USDemo$year),2015),TRMFratesF[21,1:83],
     xlab="Years",ylab="Log Death Rates",type="l",col="red",lty=1, xlim=c(1933,2075), 
     ylim = c(-12,-4),lwd=1,cex.lab=1.3,cex.axis=1.3)
lines(seq(2015,2015+nfuture),TRMFratesF[21,83:143],col="red",lty=2,
      lwd=2)
lines(seq(min(USDemo$year),2015),TRMFratesF[31,1:83],col="blue",lty=1,lwd=1)
lines(seq(2015,2015+nfuture),TRMFratesF[31,83:143],col="blue",lty=2,
      lwd=2)
lines(seq(min(USDemo$year),2015),TRMFratesF[41,1:83],col="gray",lty=1,
      lwd=1)
lines(seq(2015,2015+nfuture),TRMFratesF[41,83:143],col="gray",lty=2,
      lwd=2)
lines(seq(min(USDemo$year),2015),TRMFratesF[51,1:83],col="green",lty=1,
      lwd=1)
lines(seq(2015,2015+nfuture),TRMFratesF[51,83:143],col="green",lty=2,
      lwd=2)
lines(seq(2015,2015+nfuture), ratesF[21,83:143],col="red",lty=4)
lines(seq(2015,2015+nfuture), ratesF[31,83:143],col="blue",lty=4)
lines(seq(2015,2015+nfuture), ratesF[41,83:143],col="gray",lty=4)
lines(seq(2015,2015+nfuture), ratesF[51,83:143],col="green",lty=4)

legend("bottomleft", ncol=2, c("Age 20","Age 30","Age 40","Age 50", "Predict (RMF)","Predict(LC)","Actual"),
       col=c("red","blue","gray", "green","black","black","black"),lty=c(1,1,1,1,2,4,1),lwd=c(1,1,1,1,2,1,1),
       cex=1.3,bty = "n")

#for lengend outside the plot
#legend(2080,-4.5, ncol=1, c("Age 20","Age 30","Age 40","Age 50", "Predict (RMF)","Predict(LC)","Actual"),
#       col=c("red","blue","gray", "black","black","black"),lty=c(1,1,1,1,2,4,1),lwd=c(1,1,1,1,2,1,1),
#       cex=0.8,bty = "n")

#=====================================Figure_11=======================================
## plot future mortality rates for all ages in a specific future year
## plot 1 of Figure 11
plot(ratesF[,"2030"],type="l",xlab="Age",ylab="Log Death Rate",col=2,lty=2,
     cex.lab=1.3, cex.axis=1.3)
lines(TRMFratesF[,98],col=1,lty=1,lwd=1)
legend("bottomright",c("Predict (RMF)","Predict (LC)"),col=c(1,2),lty = c(1,2),lwd = c(1,1),bty="n",
       cex=1.3)
## plot 2 of Figure 11
plot(ratesF[,"2060"],type="l",xlab="Age",ylab="Log Death Rate",col=2,lty=2,
     cex.lab=1.3, cex.axis=1.3)
lines(TRMFratesF[,128],col=1,lty=1,lwd=1)
legend("bottomright",c("Predict (RMF)","Predict (LC)"),col=c(1,2),lty = c(1,2),lwd = c(1,1),bty="n",
       cex=1.3)


#==================================Figure_12_Age_20======================================
plot(seq(1933,2015),log(qxt[21,1:83]),type="l",ylim=c(-9.5,-5.5),xlim = c(1933,2075),
     xlab="Year",ylab="Log Death Rate", cex.lab=1.3, cex.axis=1.3)
TRMF_future20 <- t(log(read.csv("TRMFPI_female_future_20.csv",header = F)))
TRMF_future20 <- rbind(log(qxt[21,83]), TRMF_future20)
lines(seq(2015,2075),TRMF_future20[,2],col=2)
lines(seq(2015,2075),TRMF_future20[,1],col=2,lty=2)
lines(seq(2015,2075),TRMF_future20[,3],col=2,lty=2)
legend("topright", c("RMF Predicted","RMF 95% PI", "Historical actual"), col=c(2,2,1), lty=c(1,2,1),bty="n", cex=1.3)

#===================================Figure_12_Age_80======================================
plot(seq(1933,2015),log(qxt[81,1:83]),type="l",ylim=c(-3.7,-2),xlim = c(1933,2075),
     xlab="Year",ylab="Log Death Rate",cex.lab=1.3, cex.axis=1.3)
TRMF_future80 <- t(log(read.csv("TRMFPI_female_future_80.csv",header = F)))
TRMF_future80 <- rbind(log(qxt[81,83]),TRMF_future80)
lines(seq(2015,2075),TRMF_future80[,2],col=2)
lines(seq(2015,2075),TRMF_future80[,1],col=2,lty=2)
lines(seq(2015,2075),TRMF_future80[,3],col=2,lty=2)
legend("topright", c("RMF Predicted","RMF 95% PI", "Historical actual"), col=c(2,2,1), lty=c(1,2,1),bty="n", cex=1.3)

