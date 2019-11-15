# rmf_mortality

Software Dependency
===================
The plots/tables were produced under the following softwares
1. R version 3.4.0
2. Matlab 2017a
3. R packages
   3.1  demography 1.20
   3.2  StMoMo 0.4.1
   3.3  fanplot 3.4.1
4. Operating system: Ubuntu 16.04.3 LTS

[Important Notes]:
1. The Matlab package "trmf-exp-0.1" should be firstly downloaded from https://github.com/rofuyu/exp-trmf-nips16 and it can NOT be run on windows,
   and its readme file says it could be run on MACOS but we have only used/tested it on Linux (Ubuntu).
2. The data used here ("USMx90.csv")is central mortality rates (Mx_1x1) for ages 0-90+, which should be downloaded and processed from The Human Mortality Database (https://www.mortality.org/)

Guidlines for Reproduction
=========================
1. Before reproduction
   - Setup matlab
     Before using the matlab scripts here, one needs to first install the trmf-exp-0.1 by running the "install.m" script in it.
   - Setup R
     Install the packages listed above.

2. For specific tables and figures
    - Table 2
      For the results of M1-M3, run "./Table3.R"; For the result of RMF, run "./trmf-exp-0.1/table_3.m" (need to first install trmf-exp).
    
    - Table 4
      First run "./trmf-exp-0.1/table_5.m" to generate "./trmf-exp-0.1/Rolling Forecast Evaluation.csv" then run "Table4.R”.

    - Table 5 and 6
      First run "Table_5_6.m” to generate "TRMF_future_Female95.csv". Then run "Table_5_6.R” to generate the numbers in the table. Please note that you need to change the value of "age_ax" in "Table_5_6.R”
      to 35,45,55,65 and 75 to get the different values corresponding to the five ages, respectively.
    
    - Figure 6 and 7
      First, need to run "./trmf-exp-0.1/table_3.m" to generate "TRMF_US1933_norm_testmx.csv", then run "Figure_6_7.R".

      
    - Figure 8, 9, and 10
      FIrst, run "normalization_overall_mean_0726.m" to generate "TRMF_future.csv", "TRMFPI_female_future_20.csv" and "TRMFPI_female_future_80.csv" then run "Figure_8_9_10.R”.
