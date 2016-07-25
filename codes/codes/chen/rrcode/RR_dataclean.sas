libname W1 'C:\Users\Admin\Desktop\loan\RRlagerthan0_program\dataset';
libname o 'C:\Users\Admin\Desktop\loan\Loss_Modeling\DATASET';
/*******************************************************************************************/
data w1.Loan_credit_rr;
set w1.Loan_credit_rr;
CreditHistory_Byear=intck('year',FirstRecordedCreditLine_num,loanoriginationdate_num);
if EmploymentStatus=' ' then EmploymentStatus='Full-time';
drop ProsperScore_num ;
/*delete ProsperScore_num because 100% miss*/
run;
proc stdize data=w1.Loan_credit_rr reponly method=median out=w1.Loan_credit_rr_Nmiss;
var _numeric_;
run;
proc univariate data=w1.Loan_credit_rr_Nmiss;
var LoanOriginationDate_num;
output out=p pctlpts  =80 pctlpre=p80;
run;
/*THE REASON */
data w1.Loan_credit_rr_train w.Loan_credit_rr_hold;
set w1.Loan_credit_rr_Nmiss;
if  LoanOriginationDate_num<=18658 then output w.Loan_credit_rr_train;
else output w.Loan_credit_rr_hold;
run;
/*******cluster*******/
proc means data=w1.Loan_credit_rr_train noprint nway;
class EmploymentStatus;
var rr;
output out=level mean=rr;
run;

proc cluster data=level method=ward outtree=fortree;
freq _freq_;
var rr;
id EmploymentStatus;
run;
/*****cluster*end*****/

data w1.Loan_credit_rr_train;
set w1.Loan_credit_rr_train;
if EmploymentStatus in ('Not available','Self-employed','Retired') then clu_ES='NA&SE&R';
else if EmploymentStatus in ('Employed','Full-time') then clu_ES='FT&E';
else clu_ES='other';
if incomerange in ('$75,000-99,999','Not employed', '$1-24,999','$50,000-74,999') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3'; 
run;

/*handle the clu_ES of hold*/
proc freq data=W1.Loan_credit_rr_hold;
tables EmploymentStatus;
run;
data W1.Loan_credit_rr_hold;
set W1.Loan_credit_rr_hold;
if EmploymentStatus in ('Not available','Self-employed','Retired') then clu_ES='NA&SE&R';
else if EmploymentStatus in ('Employed','Full-time') then clu_ES='FT&E';
else clu_ES='other';
if incomerange in ('$75,000-99,999','Not employed', '$1-24,999','$50,000-74,999') then IR='1';
else if incomerange in ('$100,000+','$25,000-49,999') then IR='2';
else IR='3'; 
run;

data W1.Loan_credit_rr_train;
set W1.Loan_credit_rr_train;
if CurrentlyInGroup='False' then CurrentlyInGroup_Find=1;
else  CurrentlyInGroup_Find=0;
if IR='1' then IR_1ind=1 ;else IR_1ind=0;
if IR='2' then IR_2ind=1;else IR_2ind=0;
run;


data W1.Loan_credit_rr_hold;
set W1.Loan_credit_rr_hold;
if CurrentlyInGroup='False' then CurrentlyInGroup_Find=1;
else  CurrentlyInGroup_Find=0;
if IR='1' then IR_1ind=1 ;else IR_1ind=0;
if IR='2' then IR_2ind=1;else IR_2ind=0;
run;

PROC EXPORT DATA=W1.Loan_credit_rr_train
OUTFILE="C:\Users\Admin\Desktop\loan\RRlagerthan0_program\dataset\Loan_credit_rr_train.CSV"
DBMS=CSV
REPLACE;
RUN;
PROC EXPORT DATA=W1.Loan_credit_rr_hold
OUTFILE="C:\Users\Admin\Desktop\loan\RRlagerthan0_program\dataset\Loan_credit_rr_hold.CSV"
DBMS=CSV
REPLACE;
RUN;
