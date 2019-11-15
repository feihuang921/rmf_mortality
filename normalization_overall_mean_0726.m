%% import dataset
%Female
field1 = 'Ycoo';
field2 = 'Ymat';
nyr=83;
nage=91;
USMx90 = readtable('./data/USMx90.csv');
A = repelem(1:nyr,nage)';
MxF = table2array(USMx90(:,3));
%% train validation testing
ntrain = 43;
nval = 20;
ntest = 20;
%% take logrithm of Mx
logMxF = log(MxF);
Ymat0 = vec2mat(logMxF,nage)';
%calculate the ax for training dataset
axtrain = mean(mean(Ymat0(:,1:ntrain)));
Axtrain = repmat(axtrain,nyr*nage,1) ;
Axtrainmat = repmat(axtrain,nage,nyr) ;
%calculate the ax for training + testing datasets
axtrval = mean(mean(Ymat0(:,1:ntrain+nval)));
Axtrval = repmat(axtrval,nyr*nage,1);
Axtrvalmat = repmat(axtrval,nage,nyr);
Age = repmat(1:nage,1,nyr)';
% calculate the a for the whole dataset (for predict future years)
ax = mean(mean(Ymat0));
Ax = repmat(ax,nyr*nage,1);
Axmat = repmat(ax,nage,nyr);
% Ycoo --> logmx-ax(train)
% for using the training ax
Ycoo = table2array(table(Age,A,logMxF-Axtrain));
Ymat = Ymat0 - Axtrainmat;
% for using the traing+validation ax
Ycoofit = table2array(table(Age,A,logMxF-Axtrval));
Ymatfit = Ymat0 - Axtrvalmat;
% for using the whole data set (for predict future years)
Ycoofinal = table2array(table(Age,A,logMxF-Ax));
Ymatfinal = Ymat0 - Axmat;
% orginal logmx for MSE calculation
Ycoo0 = table2array(table(Age,A,logMxF));
%% training set 
Ycoo_train = Ycoo(1:ntrain*nage,:);
Ymat_train = Ymat(:,1:ntrain);
% validation set
Ymat_val = Ymat0(:, (ntrain + 1):(ntrain + nval));
% training + validation set
Ymat_trvalm = Ymat0(:,1 :(ntrain + nval));
Ymat_trval = Ymatfit(:,1:(ntrain + nval));
Ycoo_trval = Ycoofit(1:(ntrain + nval)*nage,:);
%testing set
Ymat_test = Ymat0(:, (ntrain + nval + 1):(ntrain + nval + ntest));
% use to fit the final model for prediction future years .....

%%
par = [0.00001,0.0001,0.001,0.01,0.1,1,10,100];
dim = [1,2,3,4,5];
MSEmat = zeros(numel(par)^3*numel(dim),5); %matrix to store values of MSE for each combination;
% pp = 1
% for m = 1:numel(par)
%     for n = 1:numel(par)
%         for p = 1:numel(par)
%             for k = 1:numel(dim)
%                 K = dim(k);
%                 lambda = [par(m),par(n),par(p)];
%                 model = trmf_train(size(Ymat_train), Ycoo_train, 1, K, lambda,1000,1);
%                 [Ynew_val,Xnew_val] = trmf_forecast(model,nval);
%                 err = immse(Ymat_val,Ynew_val+repmat(axtrain,nage,nval));
%                 MSEmat(pp,1:5) = [par(m),par(n),par(p),dim(k),err];
%                 pp = pp + 1
%             end
%         end
%     end
% end
% %% find the minimum MSE
% find(MSEmat(:,5)==min(MSEmat(:,5)))
% position = find(MSEmat(:,5)==min(MSEmat(:,5)));
% lambda_best = [MSEmat(position,1),MSEmat(position,2),MSEmat(position,3)];
% K_best = [MSEmat(position,4)];

lambda_best = [0.0010,  100.0000,  0.0001];
K_best = 5;




%% using training + validation set
model = trmf_train(size(Ymat_trval), Ycoo_trval, 1, K_best, lambda_best,1000,1);
[Ynew_test,Xnew_test] = trmf_forecast(model,ntest);
%caculate the MSE
immse(Ynew_test+repmat(axtrval,nage,ntest),Ymat_test) %0.0140;

%%
%generate dataset TRMF_US1933_norm_testmx
%generate dataset FOR X & F seperately
Ynew_testm = Ynew_test+repmat(axtrval,nage,ntest);
filename = 'TRMF_US1933_norm_testmx';
xlswrite(filename,Ynew_testm,1);
filenameX = 'TRMF_US1933_norm_Female_X';
xlswrite(filenameX,transpose(model.X),1);
filenameF = 'TRMF_US1933_norm_Female_F';
xlswrite(filenameF,transpose(model.F),1);
%%
%build prediction intervals for different ages
PIage=[20,30,60,80];
K=5;
PImatrix = zeros(3*numel(PIage),ntest);
%%
for q=1:numel(PIage)
   age = PIage(q);
   lag_val = model.lag_val;
   fitx = model.X.*lag_val;
   residual = model.X(:,2:ntrain+nval)-fitx(:,1:ntrain+nval-1);
   stds = zeros(K,1);
   for m = 1:K
     stds(m,1) = std(residual(m,:));
   end

   XtestU = zeros(K,ntest);
   XtestL = zeros(K,ntest);
   for k = 1:K
      for l = 1:ntest
        XtestU(k,l) = Xnew_test(k,l) + 1.96*stds(k,1)*sqrt(1+l*lag_val(k,1)^2);
        XtestL(k,l) = Xnew_test(k,l) - 1.96*stds(k,1)*sqrt(1+l*lag_val(k,1)^2);
      end      
   end  
   upper = model.F(age+1,:)*XtestU + repmat(axtrval,1,ntest);
   lower = model.F(age+1,:)*XtestL + repmat(axtrval,1,ntest);
   PI = [exp(upper);exp(lower)];

   fitY = model.F(age+1,:)*model.X + repmat(axtrval,1,63);
   trueY = Ymat0(age+1,1:63);
   Yresidual = fitY - trueY;
   Ystd = std(Yresidual)
      for i = 1:ntest
        Ynew_testU(i) = upper(:,i) + 1.96*Ystd;
        Ynew_testL(i) = lower(:,i) - 1.96*Ystd;
      end   
  %generate predicted value and PI for each age
    PImatrix(((3*(q-1)+1):q*3),:) = [Ynew_testU;Ynew_test(age+1,:)+repmat(axtrval,1,ntest);Ynew_testL];
end
PImatrixm = exp(PImatrix);
%%
filename = 'TRMFPI_US1933_norm_female';
xlswrite(filename,PImatrixm,1);
%%
%predict future n years mortality rates
ntrain_future = 43;
nval_future = 40;
logMxF = log(MxF);
Ymat0 = vec2mat(logMxF,nage)';
%calculate the ax for training dataset
axtrain_future = mean(mean(Ymat0(:,1:ntrain_future)));
Axtrain_future = repmat(axtrain_future,nyr*nage,1) ;
Axtrainmat_future = repmat(axtrain_future,nage,nyr) ;
%calculate the ax for training + testing datasets;
axtrval_future = mean(mean(Ymat0(:,1:ntrain_future+nval_future)));
Axtrval_future = repmat(axtrval_future,nyr*nage,1);
Axtrvalmat_future = repmat(axtrval_future,nage,nyr);
Age = repmat(1:nage,1,nyr)';
% Ycoo --> logmx-ax(train)
% for using the training ax
Ycoo_future = table2array(table(Age,A,logMxF-Axtrain_future));
Ymat_future = Ymat0 - Axtrainmat_future;
% for using the traing+validation ax
Ycoofit_future = table2array(table(Age,A,logMxF-Axtrval_future));
Ymatfit_future = Ymat0 - Axtrvalmat_future;
% orginal logmx for MSE calculation
Ycoo0 = table2array(table(Age,A,logMxF));
%% training set 
Ycoo_train_future = Ycoo_future(1:ntrain_future*nage,:);
Ymat_train_future = Ymat_future(:,1:ntrain_future);
% validation set
Ymat_val_future = Ymat0(:, (ntrain_future + 1):(ntrain_future + nval_future));
% training + validation set
Ymat_trvalm_future = Ymat0(:,1 :(ntrain_future + nval_future));
Ymat_trval_future = Ymatfit_future(:,1:(ntrain_future + nval_future));
Ycoo_trval_future = Ycoofit_future(1:(ntrain_future + nval_future)*nage,:);
%%
%select a new best parameters
par = [0.00001,0.0001,0.001,0.01,0.1,1,10,100];
dim = [1,2,3,4,5];
% MSEmat = zeros(numel(par)^3*numel(dim),5) %matrix to store values of MSE for each combination
% pp = 1
% for m = 1:numel(par)
%     for n = 1:numel(par)
%         for p = 1:numel(par)
%             for k = 1:numel(dim)
%                 K = dim(k);
%                 lambda = [par(m),par(n),par(p)];
%                 model = trmf_train(size(Ymat_train_future), Ycoo_train_future, 1, K, lambda,1000,1);
%                 [Ynew_future_val,Xnew_future_val] = trmf_forecast(model,nval_future);
%                 err = immse(Ymat_val_future,Ynew_future_val+repmat(axtrain_future,nage,nval_future));
%                 MSEmat(pp,1:5) = [par(m),par(n),par(p),dim(k),err];
%                 pp = pp + 1
%             end
%         end
%     end
% end
% %%
% find(MSEmat(:,5)==min(MSEmat(:,5)))
% position = find(MSEmat(:,5)==min(MSEmat(:,5)));
% lambda_best = [MSEmat(position,1),MSEmat(position,2),MSEmat(position,3)];
% K_best = [MSEmat(position,4)];

lambda_best = [0.0010, 100.0000, 0.0010];
K_best = 5;


%%
n=60;
finalmodel = trmf_train(size(Ymat_trval_future), Ycoo_trval_future, 1, K_best, lambda_best,1000,1);
[Ynew_future,Xnew_future] = trmf_forecast(finalmodel,n);
Ynew_futurem = Ynew_future+repmat(axtrval_future,nage,n);
%generate the future 60 years' results
%%
filename = 'TRMF_future';
xlswrite(filename,Ynew_futurem,1);
%%
%build prediction interval for the future years_final
%calculate the standard residuals from Y response variable
PIage=80;
finalfitY = finalmodel.F(PIage+1,:)*finalmodel.X+repmat(ax,1,nyr);
finaltrueY = Ymat0(81,:);
finalYresidual = exp(finalfitY) - exp(finaltrueY);
finalYstd = std(finalYresidual);
%%
%caculate the standard errors from prediction of X variable
K=K_best;
lag_val = finalmodel.lag_val;
fitx = finalmodel.X.*lag_val;
residual = finalmodel.X(:,2:nyr)-fitx(:,1:(nyr-1));
%hist(residual(1,:))
%hist(residual(2,:))
stds = zeros(K,1);
for k = 1:K
    stds(k,1) = std(residual(k,:));
end

%%
%calculate the upper and lowerbound considering X
XtestU = zeros(K,n);
XtestL = zeros(K,n);
for k = 1:K
  for q = 1:n
        XtestU(k,q) = Xnew_future(k,q) + 1.96*stds(k,1)*sqrt(1+q*lag_val(k,1)^2);
        XtestL(k,q) = Xnew_future(k,q) - 1.96*stds(k,1)*sqrt(1+q*lag_val(k,1)^2);
   end      
end  
%%
%add the standard errors come from prediction of final response variable
%lowerbound, predictred, and upperbound for a specific year age.
upper = exp(finalmodel.F(81,:)*XtestU + repmat(ax,1,n))+1.96*finalYstd %ax is the 83 years' overall mean;
predict = exp(Ynew_future(81,:)+repmat(ax,1,n));
lower = exp(finalmodel.F(81,:)*XtestL + repmat(ax,1,n))-1.96*finalYstd;
age80_future= [upper;predict;lower];
%%
filename='TRMFPI_female_future_80';
xlswrite(filename,age80_future,1);


upper = exp(finalmodel.F(21,:)*XtestU + repmat(ax,1,n)+1.96*finalYstd) %ax is the 83 years' overall mean;
predict = exp(Ynew_future(21,:)+repmat(ax,1,n));
lower = exp(finalmodel.F(21,:)*XtestL + repmat(ax,1,n)-1.96*finalYstd);
age20_future= [upper;predict;lower];
%%
filename='TRMFPI_female_future_20';
xlswrite(filename,age20_future,1);
