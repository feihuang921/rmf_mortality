library(demography)
library(StMoMo)
USDemo<-read.demogdata('data/Mx_1x1.txt','data/Exposures_1x1.txt', type="mortality", label="U.S.A")
USDemoF<-StMoMoData(USDemo, series = "female")
attach(USDemoF)
ntrain <- 63
ntest <- 20
wxt <- genWeightMat(0:90, 1933:(1933+ntrain-1))

set.seed(123)
#==============================fit M1==========================================
LCfit <- fit(lc(),data = USDemoF,ages.fit = 0:90,years.fit = 1933:(1933+ntrain-1))
plot(LCfit)
LCfor<-forecast(LCfit, h=ntest)
predlogMxF <- log(LCfor$rates)
MxF_val <- USDemo$rate$female[1:91,(ntrain+1):(ntrain+ntest)]
logMxF_val <- log(MxF_val)
mean((logMxF_val-predlogMxF)^2) 
# MSE = 0.04997942

#================================M2==============================================
#fit RH model 
wxt <- genWeightMat(0:90, 1933:(1933+ntrain-1))
RHfit <- fit(rh(), data=USDemoF, ages.fit = 0:90, years.fit = 1933:(1933+ntrain-1),wxt=wxt,
             start.ax = LCfit$ax, start.bx = LCfit$bx, start.kt = LCfit$kt)
plot(RHfit)
RHfor <- forecast(RHfit, h=ntest)
#computation of MSE
predlogMxF <- log(RHfor$rates)
MxF_val <- USDemo$rate$female[1:91,(ntrain+1):(ntrain+ntest)]
logMxF_val <- log(MxF_val)
mean((logMxF_val-predlogMxF)^2) 
# MSE = 0.08530193

#=====================================M3========================================
#fit the APC model
APCfit <- fit(apc(), data=USDemoF, ages.fit = 0:90, years.fit = 1933:(1933+ntrain-1),wxt=wxt)
plot(APCfit,parametricbx=FALSE,nCol=3)

APCfor <- forecast(APCfit, h=ntest)

#computation of MSE
predlogMxF <- log(APCfor$rates)
MxF_val <- USDemo$rate$female[1:91,(ntrain+1):(ntrain+ntest)]
logMxF_val <- log(MxF_val)
mean((logMxF_val-predlogMxF)^2) 
# MSE = 0.1124973

