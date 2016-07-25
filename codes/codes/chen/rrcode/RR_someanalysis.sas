proc univariate data=w.Loan_credit_rr_Nmiss;
var RR;
histogram;
cdfplot;
run;
proc sql;
create table Loan_credit_rr_Nmiss as
select *,avg(RR) as ave_rr
from w.Loan_credit_rr_Nmiss
group by LoanOriginationDate_num;
quit;
ods graphics on;
proc gplot data=Loan_credit_rr_Nmiss;
plot ave_rr*LoanOriginationDate_num;
run;
ods graphics off;
proc reg data=Loan_credit_rr_Nmiss;
model ave_rr=LoanOriginationDate_num;
run;
