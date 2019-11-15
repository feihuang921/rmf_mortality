set.seed(123)
############using rolling forecast method to assess the performance####################
#================================== M1==========================================
roll_start = 40
yr = 10
MSE_final = rep(0,(83-roll_start-2*yr+1)) 
for (i in 1:(83-roll_start-2*yr+1)){
  LCfit.RF <- fit(lc(),data = USDemoF, ages.fit = 0:90, years.fit = 1933:(1933+roll_start+yr+i-2))
  LCfor.RF <- forecast(LCfit.RF,h=yr)
  MxF_val <- USDemo$rate$female[1:91,(roll_start+yr+i):(roll_start+2*yr+i-1)]
  logMxF_val <- log(MxF_val)
  logLCfor.RF <- log(LCfor.RF$rates)
  MSE_final[i] <- mean((logMxF_val-logLCfor.RF)^2) 
}

#conduct a two sample t test to investigate if there is a significant difference between two method
MSE_TRMF <- read.csv("./trmf-exp-0.1/Rolling Forecast Evaluation.csv",header=F)
MSE_final_TRMF <- MSE_TRMF[,1]
t.test(MSE_final_TRMF, MSE_final, alternative = "less",paired = TRUE)

#================================== M2==========================================
roll_start = 40
yr = 10
MSE_final = rep(0,(83-roll_start-2*yr+1)) 
for (i in 1:(83-roll_start-2*yr+1)){
  wxt <- genWeightMat(0:90, 1933:(1933+roll_start+yr+i-2))
  LCfit.RF <- fit(lc(),data = USDemoF, ages.fit = 0:90, years.fit = 1933:(1933+roll_start+yr+i-2))
  RHfit.RF <- fit(rh(), data=USDemoF, ages.fit = 0:90, years.fit = 1933:(1933+roll_start+yr+i-2),wxt=wxt,
                  start.ax = LCfit.RF$ax, start.bx = LCfit.RF$bx, start.kt = LCfit.RF$kt)
  RHfor.RF <- forecast(RHfit.RF,h=yr)
  MxF_val <- USDemo$rate$female[1:91,(roll_start+yr+i):(roll_start+2*yr+i-1)]
  logMxF_val <- log(MxF_val)
  logRHfor.RF <- log(RHfor.RF$rates)
  MSE_final[i] <- mean((logMxF_val-logRHfor.RF)^2) 
}

#conduct a two sample t test to investigate if there is a significant difference between two method
MSE_TRMF <- read.csv("./trmf-exp-0.1/Rolling Forecast Evaluation.csv",header=F)
MSE_final_TRMF <- MSE_TRMF[,1]
t.test(MSE_final_TRMF, MSE_final, alternative = "less",paired = TRUE)


#================================== M3==========================================
roll_start = 40
yr = 10
MSE_final = rep(0,(83-roll_start-2*yr+1)) 
for (i in 1:(83-roll_start-2*yr+1)){
  wxt <- genWeightMat(0:90, 1933:(1933+roll_start+yr+i-2),clip = 3)
  APCfit.RF <- fit(apc(), data=USDemoF, ages.fit = 0:90, years.fit = 1933:(1933+roll_start+yr+i-2),wxt=wxt)
  APCfor.RF <- forecast(APCfit.RF,h=yr,kt.method = 'iarima')
  MxF_val <- USDemo$rate$female[1:91,(roll_start+yr+i):(roll_start+2*yr+i-1)]
  logMxF_val <- log(MxF_val)
  logAPCfor.RF <- log(APCfor.RF$rates)
  MSE_final[i] <- mean((logMxF_val-logAPCfor.RF)^2) 
}

#conduct a two sample t test to investigate if there is a significant difference between two method
MSE_TRMF <- read.csv("./trmf-exp-0.1/Rolling Forecast Evaluation.csv",header=F)
MSE_final_TRMF <- MSE_TRMF[,1]
t.test(MSE_final_TRMF, MSE_final, alternative = "less",paired = TRUE)

