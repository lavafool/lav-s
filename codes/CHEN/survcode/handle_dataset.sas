libname w 'C:\Users\Admin\Desktop\loan\quantlife';
data w.Loan_credit_total1_train10000cle;
set w.Loan_credit_total1_train10000;
if clu_ES='NA&SE&R' then clu_ES='NA_SE_R';
run;
proc export data=w.Loan_credit_total1_train10000cle
outfile='C:\Users\Admin\Desktop\loan\quantlife\loan_credit_total1_train10000cle.CSV'
dbms=csv
replace;
run;
proc surveyselect data=w.Loan_credit_total1_train10000cle method=seq n=1000 out=w.Loan_credit_total1_train1000cle;
run;
proc export data=w.Loan_credit_total1_train1000cle
outfile='C:\Users\Admin\Desktop\loan\quantlife\loan_credit_total1_train1000cle.CSV'
dbms=csv
replace;
run;
data W.loan_credit_total1_hold4286clean;
set w.loan_credit_total1_hold4286(keep= CreditScoreRangeLower_num
         InquiriesLast6Months_num
         ProsperRating__numeric
         clu_ES
         IR
         MonthlyLoanPayment_num
         LoanOriginalAmount_num
         CurrentDelinquencies_num
         TradesOpenedLast6Months_num
         OpenRevolvingAccounts_num
         TotalInquiries_num
         StatedMonthlyIncome_num
         Investors_num
         OpenRevolvingMonthlyPayment_num
         EmploymentStatusDuration_num
         BankcardUtilization_num);
if clu_ES='NA&SE&R ' then clu_ESNA_SE_R =1 ;ELSE clu_ESNA_SE_R=0;
if clu_ES='other' then clu_ESother =1;ELSE clu_ESother=0;
IRb=0;IRC=0;
if IR='' then IRb=1;ELSE IRb=0;
if IR='' then IRc=1;ELSE IRC=0;
KEEP CreditScoreRangeLower_num      
InquiriesLast6Months_num         
ProsperRating__numeric          
clu_ESNA_SE_R                  
clu_ESother                    
IRb                             
IRc                             
MonthlyLoanPayment_num          
LoanOriginalAmount_num        
CurrentDelinquencies_num       
TradesOpenedLast6Months_num   
OpenRevolvingAccounts_num      
TotalInquiries_num            
StatedMonthlyIncome_num       
Investors_num               
OpenRevolvingMonthlyPayment_num 
EmploymentStatusDuration_num    
BankcardUtilization_num ;
RUN;

PROC EXPORT DATA=W.loan_credit_total1_hold4286clean
OUTFILE='C:\Users\Admin\Desktop\loan\quantlife\loan_credit_total1_hold4286clean.CSV'
DBMS=CSV REPLACE;
RUN;
proc import datafile='C:\Users\Admin\Desktop\loan\quantlife\loan_credit_total1_hold4286clean_cc.csv'
out=w.loan_credit_total1_hold4286cl_c
dbms=csv;
run;
proc surveyselect data=w.loan_credit_total1_hold4286cl_c method=seq n=400 out=w.Loan_credit_total1_hold400cln_c;
run;
proc export data=w.Loan_credit_total1_hold400cln_c
outfile='C:\Users\Admin\Desktop\loan\quantlife\Loan_credit_total1_hold400cln_c.CSV'
dbms=csv
replace;
run;

/*handle pred2 ouput by R*/
proc import datafile='C:\Users\Admin\Desktop\loan\quantlife\pred2.csv'
out=w.pred2
dbms=csv;
run;
%macro create(n);
%do i=1 %to &n;
data pre&i;
set w.pred2(keep=pre&i);
tau=&i/10;
rename pre&i=pred;
run;
%end;
%mend create;
%create(9)

data pred2_new;
set pre1 pre2 pre3 pre4 pre5 pre6 pre7 pre8 pre9;
run;
proc export data=pred2_new outfile='C:\Users\Admin\Desktop\loan\quantlife\pred2_new.csv'
dbms=csv
replace;
run;


