#application part (calculation of annuity)
library(demography)
library(StMoMo)
USDemo<-read.demogdata('data/Mx_1x1.txt','data/Exposures_1x1.txt', type="mortality", label="U.S.A")
USDemo<-extract.years(USDemo,1933:2015)
USDemoF<-StMoMoData(USDemo, series = "female")
attach(USDemoF)
ntrain <- 63
ntest <- 20
wxt <- genWeightMat(0:90, 1933:(1933+ntrain-1))
set.seed(123)
#future prediction for age from 0-95+ for the use of application
##===============M1 application=============
nfuture=60
LCfith <- fit(lc(),data = USDemoF,ages.fit = 0:95,years.fit = 1933:2015)
LCforh<-forecast(LCfith, h=nfuture)
ratesFh<-log(cbind(USDemo$rate$female[1:96,],LCforh$rates[1:96,]))
ratesFh[96,]=rep(0,143)

ax=0
tpx=1
age_ax=75 ## change the age to 35,45,55,65,75
rate=0.04

for (i in 1:(95-age_ax)){
  tpx=tpx*(1-exp(ratesFh[age_ax+i,83+i]))
  ax=ax+tpx*(1+rate)^-i
}
ax ## table 6

axm=0
m=10
mpx=1
tpxm=1
for (n in 1:m){
  mpx=mpx*(1-exp(ratesFh[age_ax+n,83+n]))
}
age_axm=age_ax+m
for (j in 1:(95-age_axm+1)){
  tpxm=tpxm*(1-exp(ratesFh[age_axm+j,83+j]))
  axm=axm+tpxm*(1+rate)^(-j)
}
am=(1+rate)^(-m)*mpx*axm
am ## table 7

###Using 95+ instead:
#Immediate -> 35: 20.8641; 45:18.89655; 55: 16.28592; 65: 12.9768; 75: 8.969642
#Deferred -> 35: 12.61346; 45: 10.68438; 55: 8.206058; 65: 5.197278; 75: 2.139308

#=============================M2 application
wxt <- genWeightMat(0:95, 1933:2015, clip = 3)
RHfith <- fit(rh(), data=USDemoF, ages.fit = 0:95, years.fit = 1933:2015,wxt=wxt,
              start.ax = LCfith$ax, start.bx = LCfith$bx, start.kt = LCfith$kt)
RHforh <- forecast(RHfith, h=nfuture)
ratesFh<-log(cbind(USDemo$rate$female[1:96,],RHforh$rates[1:96,]))
ratesFh[96,]=rep(0,143)

#application part (calculation of annuity)
ax=0
tpx=1
age_ax=35 ## change the age to 35,45,55,65,75
rate=0.04
##for (i in 1:(95-age_ax+1)){
for (i in 1:(95-age_ax)){
  tpx=tpx*(1-exp(ratesFh[age_ax+i,83+i]))
  ax=ax+tpx*(1+rate)^-i
}
ax ## table 6


axm=0
m=10
mpx=1
tpxm=1
for (n in 1:m){
  mpx=mpx*(1-exp(ratesFh[age_ax+n,83+n]))
}
age_axm=age_ax+m
for (j in 1:(95-age_axm+1)){
  tpxm=tpxm*(1-exp(ratesFh[age_axm+j,83+j]))
  axm=axm+tpxm*(1+rate)^(-j)
}
am=(1+rate)^(-m)*mpx*axm
am ## table 7

#Immediate -> 35: 21.32081; 45: 19.35507; 55: 16.95206; 65: 13.77836; 75:9.547188
#Deferred -> 35: 12.91181; 45: 11.10264; 55: 8.704241; 65: 5.557703; 75 2.378639:
###use 95+
#Immediate -> 35: 21.07205; 45: 19.05517; 55: 16.57487; 65: 13.36301; 75: 9.184758.
#Deferred -> 35: 12.7131; 45: 10.85787; 55: 8.442541; 65: 5.340449; 75: 2.182735.

#==========================M3 application
APCfith <- fit(apc(), data=USDemoF, ages.fit = 0:95, years.fit = 1933:2015,wxt=wxt)
APCforh <- forecast(APCfith, h=nfuture)
ratesFh<-log(cbind(USDemo$rate$female[1:96,],APCforh$rates[1:96,]))
ratesFh[96,]=rep(0,143)

ax=0
tpx=1
age_ax=75  ## change the age to 35,45,55,65,75
rate=0.04

for (i in 1:(95-age_ax)){
  tpx=tpx*(1-exp(ratesFh[age_ax+i,83+i]))
  ax=ax+tpx*(1+rate)^-i
}
ax ## table 6

axm=0
m=10
mpx=1
tpxm=1
for (n in 1:m){
  mpx=mpx*(1-exp(ratesFh[age_ax+n,83+n]))
}
mpx
age_axm=age_ax+m
for (j in 1:(95-age_axm+1)){
  tpxm=tpxm*(1-exp(ratesFh[age_axm+j,83+j]))
  axm=axm+tpxm*(1+rate)^(-j)
}
am=(1+rate)^(-m)*mpx*axm
am ## table 7


#immediate-> 35:  21.37541;  45: 19.29766; 55:16.67971; 65: 13.36793; 75: 9.265825.
#Deferred-> 35:  12.88691;  45: 10.94825; 55: 8.467207; 65: 5.37484; 75: 2.318826.
###Use 95+
#Immediate -> 35: 21.22382; 45: 19.14209; 55: 16.50143; 65: 13.15699; 75: 9.029901
#Deferred -> 35: 12.78316; 45: 10.83147; 55: 8.333981; 65:5.238534; 75: 2.14488

#====import results from TRMF method and used for application===========
#====RMF Method==========
TRMF.future95 <- read.csv("TRMF_future_Female95.csv",header = F)
TRMFratesF95<-cbind(log(USDemo$rate$female[1:96,]),TRMF.future95[1:96,])
ratesFh <- TRMFratesF95
ratesFh[96,]=rep(0,143)

ax=0
tpx=1
age_ax=75   ## change the age to 35,45,55,65,75
rate=0.04

for (i in 1:(95-age_ax)){
  tpx=tpx*(1-exp(ratesFh[age_ax+i,83+i]))
  ax=ax+tpx*(1+rate)^-i
}
ax

axm=0
m=10
mpx=1
tpxm=1
for (n in 1:m){
  mpx=mpx*(1-exp(ratesFh[age_ax+n,83+n]))
}
age_axm=age_ax+m
for (j in 1:(95-age_axm+1)){
  tpxm=tpxm*(1-exp(ratesFh[age_axm+j,83+j]))
  axm=axm+tpxm*(1+rate)^(-j)
}
am=(1+rate)^(-m)*mpx*axm
am
