%% import dataset
%Female
field1 = 'Ycoo';
field2 = 'Ymat';
nyr=83;
nage=96;
USMx95 = readtable('USMx95.csv');
A = repelem(1:nyr,nage)';
MxF = table2array(USMx95(:,3));

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

MSEmat = zeros(numel(par)^3*numel(dim),5); %matrix to store values of MSE for each combination
pp = 1;
for m = 1:numel(par)
    m
    for n = 1:numel(par)
        for p = 1:numel(par)
            for k = 1:numel(dim)
                K = dim(k);
                lambda = [par(m),par(n),par(p)];
                model = trmf_train(size(Ymat_train_future), Ycoo_train_future, 1, K, lambda,1000,1);
                [Ynew_future_val,Xnew_future_val] = trmf_forecast(model,nval_future);
                err = immse(Ymat_val_future,Ynew_future_val+repmat(axtrain_future,nage,nval_future));
                MSEmat(pp,1:5) = [par(m),par(n),par(p),dim(k),err];
                pp = pp + 1;
            end
        end
    end
end
%%
find(MSEmat(:,5)==min(MSEmat(:,5)))
position = find(MSEmat(:,5)==min(MSEmat(:,5))); %% 613
lambda_best = [MSEmat(position,1),MSEmat(position,2),MSEmat(position,3)]; %%[0.0001  100.0000    0.0010]
K_best = [MSEmat(position,4)]; %% 3
%%
n=60;
finalmodel = trmf_train(size(Ymat_trval_future), Ycoo_trval_future, 1, K_best, lambda_best,1000,1);
[Ynew_future,Xnew_future] = trmf_forecast(finalmodel,n);
Ynew_futurem = Ynew_future+repmat(axtrval_future,nage,n);
%generate the future 60 years' results
%%
filename = 'TRMF_future_Female95.csv';
%xlswrite(filename,Ynew_futurem,1);
csvwrite(filename,Ynew_futurem);