nyr=83;
nage=91;
USMx90 = readtable('USMx90.csv');

logMxF = log(MxF);
Ymat0 = vec2mat(logMxF,nage)';


ntrain0 = 40;
nval = 10;
ntest = 10;

%% do the model selection first
nr = 24;
param_best = ones(nr,4)+inf;
for i = 1 : nr
  i
  ntrain = ntrain0 + i - 1;
  [K_best, lambda_best] = trmf_hpselect(Ymat0, ntrain, nval);
  param_best(i,1) = K_best; param_best(i,2:end) = lambda_best;
end

save('param_best', 'param_best')

%% then do the prediction and compute the mse
MSE_RF = ones(nr,1) + inf;
for i = 1 : nr
  ntrain = ntrain0 + 1 - 1;
  Y_trval = Ymat0(:,1:ntrain+nval);
  axtrval = mean(Y_trval(:));
  Y_trval = Y_trval - axtrval;
  Ycoo_trval = mat2coo(Y_trval);
  Y_test = Ymat0(:,ntrain+nval+1:ntrain+nval+ntest);
  K_best = param_best(i,1);
  lambda_best = param_best(i,2:end);
  model = trmf_train(size(Y_trval), Ycoo_trval, 1, K_best, lambda_best,1000,1);
  [Ynew_test,Xnew_test] = trmf_forecast(model,ntest);
  MSE_RF(i) = immse(Ynew_test+axtrval, Y_test);
end
