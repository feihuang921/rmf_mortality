#pre-setting of Lee-Carter model building 
library(demography)
library(StMoMo)
USDemo<-read.demogdata('data/Mx_1x1.txt','data/Exposures_1x1.txt', type="mortality", label="U.S.A")
USDemoF<-StMoMoData(USDemo, series = "female")


#=======================================FEMALE===============================================
USDemoF<-StMoMoData(USDemo, series = "female")
attach(USDemoF)
ntrain <- 63
ntest <- 20
wxt <- genWeightMat(0:90, 1933:(1933+ntrain-1))

#fit the Lee-Carter model and make predictions during the testing period
LCfit <- fit(lc(),data = USDemoF,ages.fit = 0:90,years.fit = 1933:(1933+ntrain-1))
LCfor<-forecast(LCfit, h=ntest)

#======================================Figure 7===================================================
#Simulation and prediction interval
set.seed(1234)
nsim <- 1000
LCsim <- simulate(LCfit, nsim = nsim, h = ntest)
library(fanplot)
probs = c(2.5, 97.5)
qxt <- Dxt / Ext
matplot(1933:2015, qxt["60",1:83],xlim = c(1933, 2015), ylim = c(0.006, 0.02), cex.lab=1.3,cex.axis=1.3,
        type="l",lty=1,pch = 20, col = "black",log = "y", xlab = "Year", ylab = "Death Rate")
fan(t(LCsim$rates["60", ,]), start = 1996, probs = probs, n.fan = 1, fan.col = colorRampPalette("gray"), ln = NULL)
matlines(1933:2015, qxt["60", 1:83],type="l",lty=1)
matlines(1996:2015, LCfor$rates[61,],type="l",lty=2)

# predicted result from TRMF method
TRMF<-read.csv("TRMFPI_US1933_norm_female.csv",header=F)
TRMF<-cbind(qxt["60",1995-1933+1], TRMF)
matlines(1995:2015, as.vector(t(TRMF[7,])),type="l",lty=1,col = "blue")
matlines(1995:2015, as.vector(t(TRMF[8,])),type="l",lty=2,col = "blue")
matlines(1995:2015, as.vector(t(TRMF[9,])),type="l",lty=1,col = "blue")
legend("topright",c("Actual","Predicted (LC)","Predicted (RMF)","PI (RMF)","PI (LC)"),
       col=c("black","black","blue","blue","gray"),lty=c(1,2,2,1,NA),
       fill = c(NA,NA,NA,NA,"gray"),
       border = c(NA,NA,NA,NA,"gray"),
       x.intersp=c(1,1,1,1,-1),
       xjust = c(1,1,1,1,0.5),
       cex=1.3,
       text.font = 1,
       pt.cex = 1,
       bty="n")


#==============================================Figure 6=========================================
#age 20
#Simulation and prediction interval
set.seed(1234)
nsim <- 1000
LCsim <- simulate(LCfit, nsim = nsim, h = ntest)
library(fanplot)
probs = c(2.5, 97.5)
qxt <- Dxt / Ext
matplot(1933:2015, qxt["20",1:83],xlim = c(1933, 2015), ylim = c(0.0002, 0.003), 
        type="l",lty=1,pch = 20, col = "black",log = "y", xlab = "Year", ylab = "Death Rate",
        cex.lab=1.3,cex.axis=1.3)
fan(t(LCsim$rates["20", ,]), start = 1996, probs = probs, n.fan = 1, fan.col = colorRampPalette("gray"), ln = NULL)
matlines(1933:2015, as.vector(t(qxt["20", 1:83])),type="l",lty=1)
matlines(1996:2015, as.vector(t(LCfor$rates[21,])),type="l",lty=2)

# predicted result from TRMF method
TRMF<-read.csv("TRMFPI_US1933_norm_female.csv",header=F)
TRMF<-cbind(qxt["20",1995-1933+1], TRMF)
matlines(1995:2015, as.vector(t(TRMF[1,])),type="l",lty=1,col = "blue")
matlines(1995:2015, as.vector(t(TRMF[2,])),type="l",lty=2,col = "blue")
matlines(1995:2015, as.vector(t(TRMF[3,])),type="l",lty=1,col = "blue")
legend("topright",c("Actual","Predicted (LC)","Predicted (RMF)","PI (RMF)","PI (LC)"),
       col=c("black","black","blue","blue","gray"),lty=c(1,2,2,1,NA),
       fill = c(NA,NA,NA,NA,"gray"),
       border = c(NA,NA,NA,NA,"gray"),
       x.intersp=c(1,1,1,1,-0.5),
       xjust = c(1,1,1,-0.5,-1),
       cex=1.3,
       text.font = 1,
       pt.cex = 1,
       bty="n")

