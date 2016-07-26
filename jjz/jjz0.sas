libname jjz 'D:\jjz';
proc import datafile="D:\jjz\shoptable.txt" out=jjz.shop0 replace;
getnames=yes;
run;
proc import datafile="D:\jjz\contable.txt" out=jjz.con0 replace;
getnames=yes;
run;

data shop0;set jjz.shop0;sx=X*arcos(-1)/180; sy=Y*arcos(-1)/180;data con0;set jjz.con0;  cx=X*arcos(-1)/180; cy=Y*arcos(-1)/180;run;

proc optmodel;
/* specify parameters */
   set shop0;
   set con0;
   number sx{shop0};
  number sy{shop0};
number cx{con0};
number cy{con0};
number s{shop0};
number d{con0};
number p{con0};
  read data shop0 into shop0=[_N_] sx=sx sy=sy s=supply;
    read data con0 into con0=[_N_] cx=cx cy=cy d=demand p=price;
number c{i in shop0, j in con0}= 6370*arcos(sin(sy[i])*sin(cy[j])+cos(sy[i])*cos(cy[j])*cos(sx[i]-cx[j]))/10*3+6-p[j]*0.09;
/* model description */
var x{shop0,con0} >= 0 integer, f{shop0} binary, y{shop0} binary ;
min total_cost = sum{i in shop0, j in con0}c[i,j]*x[i,j]-sum{i in shop0}f[i]*6000;
constraint supply{i in shop0}: sum{j in con0}x[i,j]<=s[i];
constraint demand{j in con0}: sum{i in shop0}x[i,j]=d[j];
constraint link1{i in shop0}: sum{j in con0}x[i,j]+1-f[i]>=1;
constraint link2{i in shop0}: sum{j in con0}x[i,j]<=100000*(1-y[i]);
constraint link3{i in shop0}: 1-f[i]<=100000*y[i];
/* solve and output */
solve with milp;
print x f;
create data solution
from [shop0 con0]
={i in shop0, j in con0: x[i,j] NE 0}
amount=x;
quit;

data jjz.jjz01;
set solustion;
run;

proc contents data=solution;run;
proc univariate data=solution freq; 
var shop0;  
run;
