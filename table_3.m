%% import dataset;
nyr=83;
nage=91;
USMx90 = readtable('USMx90.csv');
A = repelem(1:nyr,nage)';
MxF = table2array(USMx90(:,3)); %Female;
                                %MxF = table2array(USMx90(:,4)); %Male;
%% train validation testing;
ntrain = 43;
nval = 20;
ntest = 20;
%% take logrithm of Mx;
logMxF = log(MxF);
Ymat0 = vec2mat(logMxF,nage)';
%calculate the ax for training dataset;
axtrain = mean(mean(Ymat0(:,1:ntrain)));
Axtrain = repmat(axtrain,nyr*nage,1) ;
Axtrainmat = repmat(axtrain,nage,nyr) ;
%calculate the ax for training + testing datasets;
axtrval = mean(mean(Ymat0(:,1:ntrain+nval)));
Axtrval = repmat(axtrval,nyr*nage,1);
Axtrvalmat = repmat(axtrval,nage,nyr);
Age = repmat(1:nage,1,nyr)';
% calculate the a for the whole dataset (for predict future years);
ax = mean(mean(Ymat0));
Ax = repmat(ax,nyr*nage,1);
Axmat = repmat(ax,nage,nyr);
% Ycoo --> logmx-ax(train);
% for using the training ax;
Ycoo = table2array(table(Age,A,logMxF-Axtrain));
Ymat = Ymat0 - Axtrainmat;
% for using the traing+validation ax;
Ycoofit = table2array(table(Age,A,logMxF-Axtrval));
Ymatfit = Ymat0 - Axtrvalmat;
% for using the whole data set (for predict future years);
Ycoofinal = table2array(table(Age,A,logMxF-Ax));
Ymatfinal = Ymat0 - Axmat;
% orginal logmx for MSE calculation;
Ycoo0 = table2array(table(Age,A,logMxF));
%% training set ;
Ycoo_train = Ycoo(1:ntrain*nage,:);
Ymat_train = Ymat(:,1:ntrain);
% validation set;
Ymat_val = Ymat0(:, (ntrain + 1):(ntrain + nval));
% training + validation set;
Ymat_trvalm = Ymat0(:,1 :(ntrain + nval));
Ymat_trval = Ymatfit(:,1:(ntrain + nval));
Ycoo_trval = Ycoofit(1:(ntrain + nval)*nage,:);
%testing set;
Ymat_test = Ymat0(:, (ntrain + nval + 1):(ntrain + nval + ntest));
% use to fit the final model for prediction future years .....;

%%;
par = [0.00001,0.0001,0.001,0.01,0.1,1,10,100];
dim = [1,2,3,4,5];
MSEmat = zeros(numel(par)^3*numel(dim),5); %matrix to store values of MSE for each combination;
pp = 1;
for m = 1:numel(par)
    for n = 1:numel(par)
        for p = 1:numel(par)
            for k = 1:numel(dim)
                K = dim(k);
                lambda = [par(m),par(n),par(p)];
                model = trmf_train(size(Ymat_train), Ycoo_train, 1, K, lambda,1000,1);
                [Ynew_val,Xnew_val] = trmf_forecast(model,nval);
                err = immse(Ymat_val,Ynew_val+repmat(axtrain,nage,nval));
                MSEmat(pp,1:5) = [par(m),par(n),par(p),dim(k),err];
                pp = pp + 1;
            end
        end
    end
end
%% find the minimum MSE;
find(MSEmat(:,5)==min(MSEmat(:,5)));
position = find(MSEmat(:,5)==min(MSEmat(:,5)));
lambda_best = [MSEmat(position,1),MSEmat(position,2),MSEmat(position,3)];
K_best = [MSEmat(position,4)];
%% using training + validation set;
model = trmf_train(size(Ymat_trval), Ycoo_trval, 1, K_best, lambda_best,1000,1);
[Ynew_test,Xnew_test] = trmf_forecast(model,ntest);
%caculate the MSE;
immse(Ynew_test+repmat(axtrval,nage,ntest),Ymat_test) %Female: 0.0140; Male:

Ynew_testm = Ynew_test+repmat(axtrval,nage,ntest);
filename = 'TRMF_US1933_norm_testmx';
xlswrite(filename,Ynew_testm,1);
