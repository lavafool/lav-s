
% the procedure of ant colony algorithm for VRP
%
% % % % % % % % % % %

%initialize the parameters of ant colony algorithms
clc;clear all;
load data.txt;
d=data(:,2:3);
d=d*pi/180;
ld=length(d(:,1));
g=data(:,4); %订单需求
lg=data(:,5);%时间窗要求
% lg=ones(ld,1);

m=ld; % 蚂蚁数
NC=300; %迭代次数
alpha=1;
belta=2;% 决定tao和miu重要性的参数
rou=0.9; %衰减系数
q0=0.95; %概率
tao0=1/(m*114); %初始信息素
Q=1; % 蚂蚁循环一周所释放的信息素
defined_phrm=tao0; % initial pheromone level value
QV=10; % 订单容量
A=[];
v=10;%速度
pun=3;%惩罚系数
c1=6;%配送单价格

% 计算两点的距离
for i=1:ld
for j=1:ld
dist(i,j)= 6370*acos(sin(d(i,2))*sin(d(j,2))+cos(d(i,2))*cos(d(j,2))*cos(d(j,1)-d(j,1)));
if i==j;
    dist(i,j)=0;
end;
end;
end;

%给tao miu赋初值
for i=1:ld
for j=1:ld
if i~=j;
tao(i,j)=defined_phrm;
end;
end;
end;

for i=1:ld
for j=1:ld
deltao(i,j)=0;
end;
end;

best_cost=10000;
for n_gen=1:NC

%print_head(n_gen);

for i=1:m
%best_solution=[];
%print_head2(i);
sumload=0;
cur_pos(i)=1;
rn=randperm(ld);%产生随机序列
n=1;
nn=1;
part_sol(nn)=1;
%cost(n_gen,i)=0.0;
n_sol=0; % 由蚂蚁产生的路径数量
t=0; %最佳路径数组的元素数为0

while sumload<=QV;

for k=1:length(rn)%提取剩余可用配送点
if sumload+g(rn(k))<=QV;
A(n)=rn(k);
n=n+1;
end;
end;

fid=fopen('out_customer.txt','a+');
fprintf(fid,'%s %i\t','the current position is:',cur_pos(i));
fprintf(fid,'\n%s','the possible customer set is:');
fprintf(fid,'\t%i\n',A);
fprintf(fid,'------------------------------\n');
fclose(fid);

p=compute_prob(A,cur_pos(i),tao,alpha,belta,part_sol,v,pun,c1,g,lg);
maxp=1e-20;
na=length(A);
for j=1:na
if p(j)>maxp;
maxp=p(j);
index_max=j;
end;
end;%p最大下标
if index_max>na;
    index_max=na;
end
old_pos=cur_pos(i);%地点转移
if rand(1)<q0;
cur_pos(i)=A(index_max);
else
krnd=randperm(na);
cur_pos(i)=A(krnd(1));
bbb=[old_pos cur_pos(i)];
ccc=[1 1];
if bbb==ccc;%防止0长度路径
cur_pos(i)=A(krnd(2));
end;
end;

tao(old_pos,cur_pos(i))=taolocalupdate(tao(old_pos,cur_pos(i)),rou,tao0);%对所经弧进行局部更新

sumload=sumload+g(cur_pos(i));

nn=nn+1;
part_sol(nn)=cur_pos(i);%构建停靠路线
temp_load=sumload;

if cur_pos(i)~=1;
rn=setdiff(rn,cur_pos(i));%移除已用配送点
rn=rn(randperm(length(rn)));
n=1;
A=[];
end;

if cur_pos(i)==1; % 如果当前点为车场,将当前路径中的已访问用户去掉后,开始产生新路径
if isempty(setdiff(part_sol,1))==0;
n_sol=n_sol+1; % 表示产生的路径数,n_sol=1,2,3,..5,6...,超过5条对其费用加上车辆的派遣费用
fid=fopen('out_solution.txt','a+');
fprintf(fid,'%s%i%s','NO.',n_sol,'条路径是:');
fprintf(fid,'%i ',part_sol);
fprintf(fid,'\n');
fprintf(fid,'%s','当前的用户需求量是:');
fprintf(fid,'%i\n',temp_load);
fprintf(fid,'------------------------------\n');
fclose(fid);
% 对所得路径进行路径内2-opt优化
final_sol=Perform2Opt(part_sol);

for nt=1:length(final_sol)% 将所有产生的路径传给一个数组
temp(t+nt)=final_sol(nt);
end;
t=t+length(final_sol)-1;
cc(n_sol)=CalculateTotalDistance(final_sol,dist,c1,pun,v,g,lg);

sumload=0;
final_sol=setdiff(final_sol,1);
rn=setdiff(rn,final_sol);
part_sol=[];
final_sol=[];
nn=1;
part_sol(nn)=cur_pos(i);
A=[];
n=1;
end;
end;

if isempty(setdiff(rn,1))==1;% 产生最后一条终点不为1的路径
    n_sol=n_sol+1;
nl=length(part_sol);
part_sol(nl+1)=1;%将路径的最后1位补1

% 对所得路径进行路径内2-opt优化
final_sol=Perform2Opt(part_sol);

for nt=1:length(final_sol); % 将所有产生的路径传给一个数组
temp(t+nt)=final_sol(nt);
end;
t=t+length(final_sol)-1;

cost(n_gen,i)=sum(cc)+CalculateTotalDistance(final_sol,dist,c1,pun,v,g,lg); %计算由蚂蚁i产生的路径总长度
cc=[];
for ki=1:length(temp)-1
deltao(temp(ki),temp(ki+1))=deltao(temp(ki),temp(ki+1))+Q/cost(n_gen,i);
end;

if cost(n_gen,i)<best_cost;
best_cost=cost(n_gen,i);
old_cost=best_cost;
best_gen=n_gen; % 产生最小费用的代数
best_ant=i; %产生最小费用的蚂蚁
best_solution=temp;
end;

if i==m; %如果所有蚂蚁均完成一次循环，则用最佳费用所对应的路径对弧进行整体更新
for ii=1:ld
for jj=1:ld
tao(ii,jj)=(1-rou)*tao(ii,jj);
end;
end;

for kk=1:length(best_solution)-1;
tao(best_solution(kk),best_solution(kk+1))=tao(best_solution(kk),best_solution(kk+1))+rou*deltao(best_solution(kk),best_solution(kk+1));
end;
end;

fid=fopen('out_solution.txt','a+');
fprintf(fid,'%s%i%s','NO.',n_sol,'路径是:');
fprintf(fid,'%i ',part_sol);
fprintf(fid,'\n');
fprintf(fid,'%s %i\n','当前的用户需求量是:',temp_load);
fprintf(fid,'%s %f\n','总费用是:',cost(n_gen,i));
fprintf(fid,'------------------------------\n');
fprintf(fid,'%s\n','最终路径是:');
fprintf(fid,'%i-',temp);
fprintf(fid,'------------------------------\n');
fclose(fid);
temp=[];

break;
end;
end;
end;
end;



